# Amazon Connect Playground

Amazon Connect接続用のInfrastructure as Code (IaC) リポジトリです。

## 概要

このリポジトリは、Amazon Connectインスタンスとその関連リソースを自動的にプロビジョニングおよび管理するためのインフラストラクチャコードを含んでいます。

## 前提条件

- AWS CLIの設定
- 適切なAWSアカウントの権限
- Amazon Connectの基本知識

## ディレクトリ構成

```
.
├── README.md
├── terraform/          # Terraformコード（予定）
├── cloudformation/     # CloudFormationテンプレート（予定）
├── scripts/           # セットアップ・デプロイスクリプト（予定）
└── docs/              # ドキュメント（予定）
```

## セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/jumpei-yamamoto/amazon-connect-playground.git
cd amazon-connect-playground
```

### 2. AWS認証情報の設定

```bash
aws configure
```

## デプロイ

詳細なデプロイ手順は、各IaCツールのディレクトリ内のREADMEを参照してください。

### Terraformを使用する場合（予定）

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### CloudFormationを使用する場合（予定）

```bash
cd cloudformation/
aws cloudformation create-stack --stack-name amazon-connect-stack --template-body file://template.yaml
```

## Amazon Connectリソース

このリポジトリで管理する予定のリソース：

- Amazon Connectインスタンス
- コンタクトフロー
- ルーティングプロファイル
- キュー
- ユーザー管理
- 電話番号の設定
- セキュリティプロファイル

## セキュリティ

- すべての機密情報は環境変数またはAWS Secrets Managerで管理してください
- 最小権限の原則に従ったIAMロールを使用してください
- リソースにはタグを適切に設定してください

## 貢献

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチをプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを作成

## ライセンス

このプロジェクトのライセンス情報については、LICENSEファイルを参照してください。

## サポート

質問や問題がある場合は、Issueを作成してください。

## 参考資料

- [Amazon Connect 開発者ガイド](https://docs.aws.amazon.com/connect/latest/adminguide/)
- [Amazon Connect API リファレンス](https://docs.aws.amazon.com/connect/latest/APIReference/)
- [AWS CloudFormation Amazon Connect リソースタイプ](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_Connect.html)