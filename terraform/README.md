# Amazon Connect Terraform Configuration

このディレクトリには、Amazon ConnectインスタンスをTerraformで管理するための設定ファイルが含まれています。

## ファイル構成

- `versions.tf` - Terraformとプロバイダーのバージョン要件
- `main.tf` - AWSプロバイダーとAmazon Connectインスタンスの設定
- `variables.tf` - すべてのパラメータの設定可能な変数
- `outputs.tf` - Connect インスタンス情報の出力設定

## 使用方法

### 前提条件

1. Terraform >= 1.0 がインストールされている
2. AWS CLIが設定され、適切な認証情報が設定されている
3. Amazon Connect サービスに対する適切なIAM権限がある

### デプロイ手順

1. **初期化**
   ```bash
   cd terraform
   terraform init
   ```

2. **設定の確認**
   ```bash
   terraform plan
   ```

3. **デプロイ実行**
   ```bash
   terraform apply
   ```

### カスタマイズ

`terraform.tfvars` ファイルを作成して設定をカスタマイズできます：

```hcl
aws_region     = "ap-northeast-1"
project_name   = "my-connect-project"
environment    = "prod"
instance_alias = "my-connect-instance"

# 認証方式の選択 (CONNECT_MANAGED または SAML)
identity_management_type = "CONNECT_MANAGED"

# 通話機能の有効/無効
inbound_calls_enabled  = true
outbound_calls_enabled = true
```

### 設定可能な変数

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `aws_region` | AWSリージョン | `us-east-1` | No |
| `project_name` | プロジェクト名 | `amazon-connect-playground` | No |
| `environment` | 環境 (dev, staging, prod) | `dev` | No |
| `instance_alias` | Amazon Connectインスタンスのエイリアス | `connect-playground` | No |
| `identity_management_type` | ID管理タイプ (CONNECT_MANAGED, SAML) | `CONNECT_MANAGED` | No |
| `inbound_calls_enabled` | インバウンド通話の有効化 | `true` | No |
| `outbound_calls_enabled` | アウトバウンド通話の有効化 | `true` | No |

### 出力値

デプロイ後、以下の情報が出力されます：

- `connect_instance_id` - Amazon ConnectインスタンスID
- `connect_instance_arn` - Amazon ConnectインスタンスARN
- `connect_instance_service_role` - サービスロールARN
- `connect_instance_status` - インスタンスステータス
- `connect_console_url` - Amazon Connectコンソールアクセス用URL

## AWSコンソールでの確認方法

### Amazon Connect コンソール

1. [Amazon Connect コンソール](https://console.aws.amazon.com/connect/)にアクセス
2. 作成したインスタンスが一覧に表示されることを確認
3. インスタンス名をクリックして詳細を表示
4. 以下の項目を確認：
   - **インスタンスエイリアス**: `terraform output connect_instance_id` の値と一致
   - **ステータス**: "ACTIVE" になっている
   - **インバウンド通話**: 設定した値と一致
   - **アウトバウンド通話**: 設定した値と一致
   - **ID管理**: 設定した認証方式と一致

### CloudFormation コンソール（参考）

1. [CloudFormation コンソール](https://console.aws.amazon.com/cloudformation/)にアクセス
2. リージョンを確認（Terraformで指定したリージョンと同じ）
3. Terraformによって作成されたリソースは直接は表示されませんが、関連するサービスロールなどが作成されている場合があります

### IAM コンソール

1. [IAM コンソール](https://console.aws.amazon.com/iam/)にアクセス
2. **ロール** セクションを確認
3. Amazon Connect用のサービスロールが作成されていることを確認
   - ロール名に "AmazonConnect" が含まれるロールを探す
   - `terraform output connect_instance_service_role` の値と一致することを確認

### 管理ポータルアクセス

Terraformの出力値 `connect_console_url` に表示されるURLにアクセスして、Amazon Connect の管理ポータルにログインできることを確認：

```bash
# URLを取得
terraform output connect_console_url
```

### リソースタグの確認

作成されたリソースに適切なタグが付与されていることを確認：

- **Project**: プロジェクト名
- **Environment**: 環境名
- **ManagedBy**: "terraform"

## トラブルシューティング

### よくあるエラー

1. **権限不足エラー**
   ```
   Error: operation error Connect: CreateInstance, https response error StatusCode: 403
   ```
   - IAMユーザー/ロールにAmazon Connect の権限が不足している
   - `AmazonConnect_FullAccess` ポリシーの付与を検討

2. **リージョンエラー**
   ```
   Error: Amazon Connect is not available in this region
   ```
   - Amazon Connect が利用可能なリージョンを指定する必要がある
   - [利用可能リージョン](https://docs.aws.amazon.com/connect/latest/adminguide/regions.html)を確認

3. **エイリアス重複エラー**
   ```
   Error: Instance alias already exists
   ```
   - 指定したインスタンスエイリアスが既に使用されている
   - `instance_alias` 変数を変更する

### クリーンアップ

リソースを削除する場合：

```bash
terraform destroy
```

**注意**: この操作により、Amazon Connectインスタンスとそれに関連する設定がすべて削除されます。