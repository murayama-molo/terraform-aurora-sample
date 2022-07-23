# terraform-aurora-sample

terraform で AWS 環境上に API Gateway, Lambda(python), CloudFront, S3, Aurora Serverless(PostgreSQL14), Waf, Cognito を作ってみるサンプル

# Requirement

以下の環境で構築しました

## aws

```bash
$ aws --version
aws-cli/2.2.25 Python/3.8.8 Darwin/21.5.0 exe/x86_64 prompt/off
```

## asdf

```bash
asdf --version
v0.10.2
```

## terraform

```bash
$ terraform -v
Terraform v1.2.5
on darwin_amd64
```

## git

```bash
$ git --version
git version 2.35.1
```

## python

```bash
$ python --version
Python 3.10.3
```

# Installation

すでにインストールされているツールはスキップしてください

## chocolatey

パッケージマネージャー

### asdf をインストール

## AWS CLI

### AWS CLI をインストール

https://docs.aws.amazon.com/ja_jp/cli/v1/userguide/install-windows.html#install-msi-on-windows

### IAM の設定

```bash
$ aws configure
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

## terraform

### インストール

```bash
$ asdf install terraform
```

### バージョンを指定して適用

```bash
$ asdf global terraform 1.0.8
```

## git

### mac

```bash
$ brew install git-lfs
```

### ubuntu

```bash
$ sudo apt-get install git
```

## python

```bash
# プラグインをインストール
$ asdf plugin-add python

# インストール可能なバージョンの確認
$ asdf list-all python

# インストール
$ asdf install python 3.10.3
```

# 初期設定

- ワークスペース名の設定を行う。
- デフォルトではユーザー名がワークスペース名として扱われる。

```bash
export TERRAFORM_WORKSPACE={TYPE_YOUR_OWN_WORKSPACE_NAME}
```

- Terraform のバックエンドに必要なリソースの作成と初期化処理を行う。

```bash
./terraform/bin/entrypoint.sh init
```

# plan

※apply するリソースの確認

```bash
$ terraform plan -var 'profile=default' -var 'domain_name=example.com' -var 'domain_name_certificate_arn=arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

# apply

```bash
$ terraform apply -var 'profile=default' -var 'domain_name=example.com' -var 'domain_name_certificate_arn=arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

# destroy

お掃除
作ったリソースを全部削除

```bash
$ terraform destroy -var 'profile=default' -var 'domain_name=example.com' -var 'domain_name_certificate_arn=arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```
