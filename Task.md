# Amazon Connect IaC Implementation Tasks

このタスクリストは、Amazon Connect検証用インフラストラクチャをAWS環境にデプロイするための詳細な実装ステップです。Claude Codeが実行可能な粒度でタスクを定義しています。

## 前提条件

- AWS CLI設定済み
- 適切なAWS権限（Amazon Connect、IAM、Lambda等）
- Terraform または CloudFormation の基本知識

## Phase 1: プロジェクト基盤構築

### Task 1: プロジェクト構造の作成
**目標**: 基本的なディレクトリ構造とファイルを作成する
**実行内容**:
- `terraform/` ディレクトリ作成
- `terraform/environments/dev/` ディレクトリ作成
- `terraform/modules/` ディレクトリ作成
- `scripts/` ディレクトリ作成
- `docs/` ディレクトリ作成

### Task 2: Terraform設定ファイルの作成
**目標**: Terraformの基本設定を構築する
**実行内容**:
- `terraform/main.tf` 作成（プロバイダー設定）
- `terraform/variables.tf` 作成（変数定義）
- `terraform/outputs.tf` 作成（出力定義）
- `terraform/versions.tf` 作成（Terraformバージョン指定）

### Task 3: AWS Provider設定
**目標**: AWS Providerの設定とリージョン指定
**実行内容**:
- AWS Provider設定（ap-northeast-1）
- S3バックエンド設定（オプション）
- Required providersブロック作成

### Task 4: 共通変数の定義
**目標**: 環境共通で使用する変数を定義する
**実行内容**:
- プロジェクト名変数
- 環境名変数（dev/staging/prod）
- タグ用変数
- リージョン変数

## Phase 2: ネットワーク基盤構築

### Task 5: VPCモジュールの作成
**目標**: Amazon Connect用VPCを作成する
**実行内容**:
- `terraform/modules/vpc/main.tf` 作成
- VPC、Subnet（public/private）の定義
- Internet Gateway、NAT Gateway設定
- Route Table設定

### Task 6: Security Groupモジュールの作成
**目標**: Amazon Connect関連のセキュリティグループを作成する
**実行内容**:
- `terraform/modules/security_groups/main.tf` 作成
- Lambda用セキュリティグループ
- Amazon Connect用セキュリティグループ
- 必要なポート開放設定

## Phase 3: IAM権限設定

### Task 7: IAMロールモジュールの作成
**目標**: Amazon Connect用IAMロールを作成する
**実行内容**:
- `terraform/modules/iam/main.tf` 作成
- Amazon Connect実行ロール
- Lambda実行ロール
- CloudWatch Logs書き込み権限

### Task 8: IAMポリシーの定義
**目標**: 必要なIAMポリシーを定義する
**実行内容**:
- Amazon Connect操作用ポリシー
- Lambda実行用ポリシー
- CloudWatch Logs用ポリシー
- KMS暗号化用ポリシー（オプション）

## Phase 4: Amazon Connect基本設定

### Task 9: Amazon Connectインスタンスモジュール作成
**目標**: Amazon Connectインスタンスを作成する
**実行内容**:
- `terraform/modules/amazon_connect/main.tf` 作成
- Connect Instance設定
- Identity Management設定
- Inbound calls設定
- Outbound calls設定

### Task 10: コンタクトフロー定義
**目標**: 基本的なコンタクトフローを作成する
**実行内容**:
- `terraform/contact_flows/` ディレクトリ作成
- `basic_flow.json` 作成（基本的な着信フロー）
- Welcome message設定
- Queue設定との連携

### Task 11: キューとルーティングプロファイル
**目標**: 基本的なキューとルーティングプロファイルを作成する
**実行内容**:
- Basic Queue設定
- Default Routing Profile設定
- Queue時間設定
- Priority設定

### Task 12: 電話番号の設定
**目標**: Amazon Connect用電話番号を設定する
**実行内容**:
- Phone Number claim設定
- DID番号の取得（開発環境用）
- コンタクトフローとの紐付け

## Phase 5: Lambda統合

### Task 13: Lambda関数モジュール作成
**目標**: Amazon Connect連携用Lambda関数を作成する
**実行内容**:
- `terraform/modules/lambda/main.tf` 作成
- Lambda関数定義
- Lambda Layer設定（オプション）
- 環境変数設定

### Task 14: Lambda関数コードの作成
**目標**: Amazon Connect用Lambda関数のソースコードを作成する
**実行内容**:
- `src/lambda/` ディレクトリ作成
- `src/lambda/connect_handler/index.js` 作成
- 基本的なConnect属性取得処理
- DynamoDB連携処理（オプション）

### Task 15: Lambda権限設定
**目標**: LambdaとAmazon Connectの連携権限を設定する
**実行内容**:
- Lambda Invoke Permission設定
- Amazon Connect → Lambda呼び出し権限
- CloudWatch Logs出力権限

## Phase 6: ログ・監視設定

### Task 16: CloudWatch Logsモジュール作成
**目標**: ログ出力用CloudWatch Log Groupを作成する
**実行内容**:
- `terraform/modules/cloudwatch/main.tf` 作成
- Amazon Connect用Log Group
- Lambda用Log Group
- Log retention期間設定

### Task 17: CloudWatch Metricsとアラーム
**目標**: 監視用メトリクスとアラームを設定する
**実行内容**:
- 通話量監視メトリクス
- Lambda実行エラーアラーム
- Amazon Connect接続エラーアラーム
- SNS通知設定（オプション）

## Phase 7: セキュリティ設定

### Task 18: KMS暗号化設定
**目標**: データ暗号化用KMSキーを設定する
**実行内容**:
- `terraform/modules/kms/main.tf` 作成
- Customer Managed Key作成
- Key Policy設定
- エイリアス設定

### Task 19: Secrets Manager設定
**目標**: 機密情報管理用Secrets Managerを設定する
**実行内容**:
- `terraform/modules/secrets/main.tf` 作成
- API Key等の機密情報格納
- Lambda環境変数からの参照設定

## Phase 8: デプロイメント・自動化

### Task 20: 環境別設定ファイル
**目標**: dev/staging/prod環境の設定ファイルを作成する
**実行内容**:
- `terraform/environments/dev/terraform.tfvars` 作成
- 環境固有の変数値設定
- リソース命名規則設定

### Task 21: デプロイスクリプト作成
**目標**: 自動デプロイ用スクリプトを作成する
**実行内容**:
- `scripts/deploy.sh` 作成
- Terraform初期化処理
- Plan実行とApply処理
- エラーハンドリング

### Task 22: CI/CD設定（GitHub Actions）
**目標**: GitHub ActionsによるCI/CDパイプラインを作成する
**実行内容**:
- `.github/workflows/terraform.yml` 作成
- Pull Request時のTerraform Plan
- Main branch merge時のTerraform Apply
- AWS認証情報設定

### Task 23: 設定値検証とテスト
**目標**: 作成したインフラの動作検証を行う
**実行内容**:
- `scripts/test_connection.sh` 作成
- Amazon Connectインスタンス接続テスト
- Lambda関数実行テスト
- コンタクトフロー動作確認

### Task 24: ドキュメント作成
**目標**: 運用・保守用ドキュメントを作成する
**実行内容**:
- `docs/deployment.md` 作成（デプロイ手順）
- `docs/troubleshooting.md` 作成（トラブルシューティング）
- `docs/architecture.md` 作成（システム構成図）
- README.md更新

### Task 25: クリーンアップスクリプト作成
**目標**: リソース削除用スクリプトを作成する
**実行内容**:
- `scripts/cleanup.sh` 作成
- Terraform Destroy処理
- S3バケット手動削除処理
- 検証用リソースの完全削除

## 実行順序

1. **Phase 1-2**: プロジェクト基盤とネットワーク構築（Task 1-6）
2. **Phase 3**: IAM権限設定（Task 7-8）
3. **Phase 4**: Amazon Connect設定（Task 9-12）
4. **Phase 5**: Lambda統合（Task 13-15）
5. **Phase 6-7**: 監視・セキュリティ設定（Task 16-19）
6. **Phase 8**: デプロイメント・自動化（Task 20-25）

## 注意事項

- 各Taskは前のTaskの完了を前提としています
- AWS料金が発生するため、不要なリソースは適切にクリーンアップしてください
- セキュリティベストプラクティスに従って実装してください
- 本番環境への適用前に十分なテストを行ってください

## 成果物

このタスクリスト完了後、以下が利用可能になります：

- 完全にコード化されたAmazon Connect環境
- 自動デプロイメント機能
- 監視・ログ出力機能
- セキュリティ設定適用済み環境
- 環境別デプロイ対応
- CI/CDパイプライン