# Wolfram KernelをJupyter Labから扱う

## 環境構築方法

### リポジトリのクローン
はじめに、リポジトリをローカル環境にクローンする。
```bash
$ git clone https://github.com/Aconitum3/Wolfram
```

### Wolfram Engineアカウントのアクティベート(コンテナ初回起動時のみ)
Wolfram Engineのアクティベートのために、次のコマンドを実行してwolframコンテナに接続する。
```bash
$ cd Wolfram/jupyter/project
$ docker-compose up -d
$ docker-compose exec wolfram bash
```
wolframコンテナのbashで、次のコマンドを実行する。
```bash
$ wolframscript -activate
> Wolfram ID: wolfram.example.com
> Password: *******
```
アクティベートできたら、次のコマンドを実行して、Jupyter LabでWolfram Kernelを利用できるようにする。
```bash
$ /WolframLanguageForJupyter/configure-jupyter.wls add
```
このまま、Jupyter Labに接続したい場合、[http://localhost:8888](http://localhost:8888)にアクセスすれば良い。次のコマンドでトークンが確認できる。
```bash
$ jupyter lab list
```
コンテナとの接続を切断するには以下のコマンドを実行する。
```bash
$ exit
```
コンテナを停止する。
```bash
$ docker-compose stop
```

### Jupyter Labの起動(2回目以降)
次のコマンドを実行して、Jupyter Labを起動する。
```bash
$ docker-compose up
```
ログに表示される`http://127.0.0.1:8888/lab?token=****`にアクセスすると、Jupyter Labに接続できる。

ここまでの手順がうまく行っていれば、Launcher画面でWolfram Language 13が選択できるはずだ。

## 各要素の説明
本環境は、Mathematicaの開発元であるWolfram ResearchがDocker Hubで公開している[wolframresearch/wolframengine](https://hub.docker.com/r/wolframresearch/wolframengine)イメージを元にしている。

本節ではDockerfileとdocker-compose.ymlの詳しい内容を説明する。
### ディレクトリ構成
```
project/
　├ Dockerfile
　├ docker-compose.yml
　├ requirements.txt
　├ Licensing/
　└ mountpoint/
```

### `Dockerfile`

```Dockerfile
FROM wolframresearch/wolframengine:13.0.1

USER root

COPY requirements.txt ./
RUN pip install --upgrade pip \
  && pip install -r requirements.txt

RUN apt-get update && apt-get install -y git \
  && git clone https://github.com/WolframResearch/WolframLanguageForJupyter.git \
  && mkdir /home/mountpoint

WORKDIR /home/mountpoint

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root
```
各コマンドについて順に説明する。

#### `USER root`
元イメージがuserをwolframengineにしており、そのままでは`apt-get`コマンドなどで権限エラーが起きるため、ユーザーをrootに変更している。
#### `RUN pip install ...`
Jupyter Labをインストールしている。`requirements.txt`は次のようになっている。
```
jupyterlab
matplotlib
numpy
pandas
```
`jupyterlab`以外はインストールしなくてもよいが、よく使われるパッケージであるためインストールしている。
####   `RUN apt-get update ...`
Wolfram ResearchがGitHubで公開している、Jupyterで動作するWolfram kernelのリポジトリ[WolframLanguageForJupyter](https://github.com/WolframResearch/WolframLanguageForJupyter)をクローンしている。コンテナ起動前は、Wolfram Engineのアクティベートがされていない。そのため、クローンしたプログラムの実行は、コンテナに接続して、アクティベートを済ませてから行う。

#### `CMD jupyter lab ...`
ROOT Processに`jupyer lab`を指定している。ROOT Processとは、コンテナ上で最初に実行されるプログラムである。ROOT Processが終了すると、コンテナは停止する。

ここで、Dockerでは`0.0.0.0`でサーバーを起動しないと、コンテナ外からアクセスできない。また、`--allow-root`を指定しないと、rootユーザーがアクセスできなくなる。

### `docker-compose.yml`
```yaml
version: "2"
services:
  wolfram:
    build:
     context: .
     dockerfile: Dockerfile
    volumes:
      - ./mountpoint:/home/mountpoint
      - ./Licensing:/root/.WolframEngine/Licensing
    ports:
      - "8888:8888"
```
作業ディレクトリ`/home/mountpoint`をローカルディレクトリ`./mountpoint`にマウントしている。

また、Wolfram Engineをrootユーザーでアクティベートした場合、ライセンス情報が`mathpass`として、`/root/.WolframEngine/Licensing/`に保存される。2回目以降のアクティベートを省略するために、ライセンス情報をローカルで管理できるようにしている。