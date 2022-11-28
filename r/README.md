# RからWolframを評価する

## 環境構築方法

### リポジトリのクローン
はじめに、リポジトリをローカル環境にクローンする。
```bash
$ git clone https://github.com/Aconitum3/Wolfram
```

### Wolfram Engineアカウントのアクティベート(コンテナ初回起動時のみ)
Wolfram Engineのアクティベートのために、initコンテナを用意している。次のコマンドを実行して、initコンテナに接続する。
```bash
$ cd Wolfram/r/project
$ docker-compose -f docker-compose-init.yml up -d
$ docker-compose -f docker-compose-init.yml exec init bash
```
initコンテナのbashで、次のコマンドを実行する。
```bash
$ wolframscript -activate
> Wolfram ID: wolfram.example.com
> Password: *******
```
アクティベートできたら、コンテナとの接続を切り、コンテナを削除する。
```bash
$ exit
```
```bash
$ docker-compose -f docker-compose-init.yml down
```

### Jupyter Labの起動
次のコマンドを実行して、Jupyter Labを起動する。
```bash
$ docker-compose up
```
ログに表示される`http://127.0.0.1:8888/lab?token=****`にアクセスすると、Jupyter Labに接続できる。

### Wolframの評価
RでWolframを評価する。sample.ipynbを実行してみる。
```R
source("/WolframConnect.R")

wolfram_evaluate("1+1")
[1] 2
```
ここまでの手順がうまくいっていれば、無事WolframをRで評価できるはずだ。

## 各要素の説明
本環境には3つのコンテナが使われる。
* initコンテナ

    Wolfram Engineのアクティベートをするためのコンテナ。プロジェクト初回実行時のみ実行が必要で、`Wstp/Dockerfile-init`、 `docker-compose-init.yml`を用いて操作する。

* jupyterコンテナ

    Jupyter Labサーバー。WstpコンテナとTCP通信を介してRでWolframを評価する。

* wstpコンテナ

    WSTPサーバー。Wolfram kernelの起動と管理を行う。

本節では各ファイルの詳しい内容を説明する。
### ディレクトリ構成
```
project/
　├ Jupyter/
　│ 　├ Dockerfile
　│ 　├ Rkernel.R
　│ 　├ WolframConnect.R
　│ 　└ requirements.txt
　├ Wstp/
　│ 　├ Dockerfile
　│ 　├ Dockerfile-init
　│ 　├ PortOpen.wls
　│ 　└ wstpserver.conf
　├ docker-compose.yml
　├ docker-compose-init.yml
　├ mountpoint/
　└ Licensing/
```

### `Jupyter/Dockerfile`

```Dockerfile
FROM python:3.7

RUN apt-get update && apt-get install -y \
    libzmq3-dev \
    r-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip
    					 
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY Rkernel.R . 

RUN Rscript Rkernel.R

EXPOSE 8888

RUN mkdir /home/mountpoint

COPY WolframConnect.R .

WORKDIR /home/mountpoint

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser
```
jupyterコンテナは、pythonイメージを元に作成している。

各コマンドについて順に説明する。

#### `RUN apt-get update ...`
Rをインストールしている。

#### `RUN pip install ...`
Jupyter Labをインストールしている。`requirements.txt`は次のようになっている。
```
jupyterlab
matplotlib
numpy
pandas
```
`jupyterlab`以外はインストールしなくてもよいが、よく使われるパッケージであるためインストールしている。

#### `RUN Rscript Rkernel.R`
`Rkernel.R`は次のようになっている。
```R
install.packages(c('repr', 'IRdisplay', 'IRkernel'), type = 'source')
install.packages("https://cran.r-project.org/src/contrib/rzmq_0.9.8.tar.gz")
install.packages("rjson")
IRkernel::installspec()
```
`repr`、`IRdisplay`、`IRkernel`はJupyter LabでR kernelを動かすためのパッケージである。

`rzmq`、`rjson`はWSTPサーバーと通信するためのパッケージである。

####   `COPY WolframConnect.R ./`
`WolframConnect.R`は次のようになっている。
```R
library(rzmq)
library(rjson)
context = init.context()
socket = init.socket(context,"ZMQ_PAIR")
connect.socket(socket,"tcp://wstp:9003")
wolfram_evaluate <- function(expression){
​
send.socket(socket,expression)
msg = rawToChar(receive.socket(socket, unserialize=FALSE, dont.wait=FALSE))
wlinput<- fromJSON(msg)$Output
return(wlinput)
}
​
```
Wolframのコードを評価する関数`wolfram_evaluate`を定義している。`source("/WolframConnect.R")`のように読み込んで使うことを想定している。

wstpコンテナの9003番ポートで通信を行っている。プロジェクト内のコンテナはDocker Composeが提供する名前解決機能により、ipアドレスを指定せず、コンテナ名を用いて、`tcp://wstp:9003`のようできる。


#### `CMD jupyter lab ...`
ROOT Processに`jupyer lab`を指定している。ROOT Processとは、コンテナ上で最初に実行されるプログラムである。ROOT Processが終了すると、コンテナは停止する。

ここで、Dockerでは`0.0.0.0`でサーバーを起動しないと、コンテナ外からアクセスできない。また、`--allow-root`を指定しないと、rootユーザーがアクセスできなくなる。

### `Wstp/Dockerfile-init`

```Dockerfile
FROM wolframresearch/wolframengine
USER root
CMD bash
```
ライセンス情報の保存先を統一するために、rootユーザーに変更している。

### `Wstp/Dockerfile`

```Dockerfile
FROM wolframresearch/wolframengine:13.0.1

USER root

COPY PortOpen.wls ./
COPY wstpserver.conf ./

CMD /usr/local/Wolfram/WolframEngine/13.0/SystemFiles/Links/WSTPServer/wstpserver
```
`/usr/local/Wolfram/WolframEngine/13.0/SystemFiles/Links/WSTPServer/wstpserver`はWSTPサーバーを起動するコマンドである。

Wolfram Engineのアクティベートがされていない場合、WSTPサーバー起動コマンド実行時にエラーとなる。

#### `PortOpen.wls`、`wstpserver.conf`
`PortOpen.wls`では、9003番ポートを解放し、jupyterコンテナからの通信の処理について記されている。

`wstpserver.conf`はWSTPサーバーの環境設定ファイルで、サーバー起動時に`PortOpen.wls`を実行するようにしている。

### `docker-compose-init.yml`
```yaml
version: "2"
services:
  init:
    build:
      context: Wstp
      dockerfile: Dockerfile-init
    tty: true
    volumes:
      - ./Licensing:/root/.WolframEngine/Licensing
```
Wolfram Engineのアクティベートに用いる。
Wolfram Engineをrootユーザーでアクティベートした場合、ライセンス情報が`mathpass`として、`/root/.WolframEngine/Licensing/`に保存される。`mathpass`をローカルにマウントすることで、wstpコンテナにライセンス情報を共有できる。


### `docker-compose.yml`
```yaml
version: "2"
services:
  jupyter:
    build:
     context: Jupyter
     dockerfile: Dockerfile
    volumes:
      - ./mountpoint:/home/mountpoint
    ports:
      - "8888:8888"
  wstp:
    build:
      context: Wstp
      dockerfile: Dockerfile
    volumes:
      - ./Licensing:/root/.WolframEngine/Licensing
```
作業ディレクトリ`/home/mountpoint`をローカルディレクトリ`./mountpoint`にマウントしている。

initコンテナで作成した認証情報をコンテナ内にマウントしている。