# RからWolframを評価する

## 環境構築方法

### リポジトリのクローン
はじめに、リポジトリをローカル環境にクローンする。
```bash
$ git clone https://github.com/Aconitum3/Wolfram
```

### Wolfram Engineアカウントのアクティベート
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
作成中...