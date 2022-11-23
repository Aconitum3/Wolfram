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
作成中...