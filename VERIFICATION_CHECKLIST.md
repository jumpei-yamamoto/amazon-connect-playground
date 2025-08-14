# Amazon Connect IaC Implementation - 確認チェックリスト

このドキュメントは、Task.mdで定義された各タスクの実装完了後の確認方法を詳細に記載しています。
各フェーズとタスクごとに、実装の正確性を検証するためのチェックポイントと確認手順を提供します。

## 確認の基本原則

### 1. ファイル存在確認
- 指定されたディレクトリとファイルが正しく作成されているかを確認
- ファイル内容が要件を満たしているかを検証

### 2. AWS リソース確認
- AWS Management Console での実際のリソース作成確認
- CLI コマンドによる設定値の検証

### 3. 動作確認
- 各機能が期待通りに動作するかのテスト
- エラーケースの対応確認

---

## Phase 1: プロジェクト基盤構築

### Task 1: プロジェクト構造の作成

#### ✅ 確認項目
- [ ] ディレクトリ構造の確認

```bash
# ディレクトリ構造の確認
ls -la
tree . -d  # treeコマンドが利用可能な場合

# 期待される構造:
# terraform/
# terraform/environments/dev/
# terraform/modules/
# scripts/
# docs/
```

#### ✅ 成功基準
- すべての必要なディレクトリが作成されている
- ディレクトリのパーミッションが適切に設定されている

---

### Task 2: Terraform設定ファイルの作成

#### ✅ 確認項目
- [ ] ファイル存在確認

```bash
# 各ファイルの存在確認
ls -la terraform/main.tf
ls -la terraform/variables.tf
ls -la terraform/outputs.tf
ls -la terraform/versions.tf
```

- [ ] ファイル内容の確認

```bash
# ファイル内容の簡易確認
cat terraform/main.tf | grep -E "(provider|resource)"
cat terraform/variables.tf | grep "variable"
cat terraform/outputs.tf | grep "output"
cat terraform/versions.tf | grep "terraform"
```

#### ✅ 成功基準
- 4つの基本設定ファイルが存在する
- 各ファイルに適切なTerraform構文が含まれている
- syntaxエラーがない

---

### Task 3: AWS Provider設定

#### ✅ 確認項目
- [ ] Provider設定の確認

```bash
# provider設定の確認
cat terraform/main.tf | grep -A 10 'provider "aws"'

# 期待される内容:
# - region = "ap-northeast-1"
# - 適切なprovider設定
```

- [ ] Terraform初期化テスト

```bash
cd terraform/
terraform init
# エラーなく初期化が完了することを確認
```

#### ✅ 成功基準
- AWS Provider が ap-northeast-1 リージョンに設定されている
- terraform init が正常に完了する
- required_providers ブロックが正しく記述されている

---

### Task 4: 共通変数の定義

#### ✅ 確認項目
- [ ] 変数定義の確認

```bash
# 変数の確認
cat terraform/variables.tf | grep -A 5 'variable'

# 必須変数の確認:
# - project_name
# - environment
# - tags
# - region
```

- [ ] 変数のバリデーション確認

```bash
cd terraform/
terraform validate
terraform plan -var="project_name=test" -var="environment=dev"
```

#### ✅ 成功基準
- すべての必須変数が定義されている
- 変数にデフォルト値または説明が設定されている
- terraform validate でエラーが発生しない

---

## Phase 2: ネットワーク基盤構築

### Task 5: VPCモジュールの作成

#### ✅ 確認項目
- [ ] モジュールファイル確認

```bash
# VPCモジュールファイルの確認
ls -la terraform/modules/vpc/
cat terraform/modules/vpc/main.tf | grep -E "(resource|data)"
```

- [ ] Terraform設定検証

```bash
cd terraform/
terraform plan
# VPC、Subnet、IGW、NATゲートウェイの作成計画を確認
```

#### ✅ AWS Management Console での確認
1. **VPCダッシュボード**にアクセス
   - URL: https://console.aws.amazon.com/vpc/
2. 作成されたVPCを確認
   - CIDR範囲が適切に設定されているか
   - パブリック・プライベートサブネットが適切に分散されているか
3. **Route Tables**の確認
   - パブリックサブネット用ルートテーブルがIGWを参照
   - プライベートサブネット用ルートテーブルがNATゲートウェイを参照

#### ✅ 成功基準
- VPC、サブネット、ゲートウェイの作成計画が適切
- ネットワーク構成がベストプラクティスに従っている
- AZ冗長化が適切に設定されている

---

### Task 6: Security Groupモジュールの作成

#### ✅ 確認項目
- [ ] セキュリティグループモジュール確認

```bash
ls -la terraform/modules/security_groups/
cat terraform/modules/security_groups/main.tf | grep "resource.*aws_security_group"
```

- [ ] ポート開放設定の確認

```bash
# セキュリティグループルールの確認
cat terraform/modules/security_groups/main.tf | grep -A 10 "ingress"
cat terraform/modules/security_groups/main.tf | grep -A 10 "egress"
```

#### ✅ AWS Management Console での確認
1. **EC2 > Security Groups**にアクセス
2. 作成されたセキュリティグループの確認
   - Lambda用セキュリティグループの存在
   - Amazon Connect用セキュリティグループの存在
3. **Inbound/Outbound Rules**の確認
   - 必要な通信のみが許可されている
   - 過度に開放的でない設定になっている

#### ✅ 成功基準
- Lambda、Amazon Connect用のセキュリティグループが作成される
- 最小権限の原則に従ったポート開放
- セキュリティベストプラクティスの遵守

---

## Phase 3: IAM権限設定

### Task 7: IAMロールモジュールの作成

#### ✅ 確認項目
- [ ] IAMロールモジュール確認

```bash
ls -la terraform/modules/iam/
cat terraform/modules/iam/main.tf | grep "resource.*aws_iam_role"
```

#### ✅ AWS Management Console での確認
1. **IAM > Roles**にアクセス
   - URL: https://console.aws.amazon.com/iam/home#/roles
2. 作成されたロールの確認
   - Amazon Connect実行ロール
   - Lambda実行ロール
3. **Trust Relationship**の確認
   - 適切なサービスプリンシパルが設定されている

#### ✅ CLI での確認
```bash
# ロール一覧の確認
aws iam list-roles --query 'Roles[?contains(RoleName, `connect`) || contains(RoleName, `lambda`)]'

# ロール詳細の確認
aws iam get-role --role-name <role-name>
```

#### ✅ 成功基準
- Amazon Connect用とLambda用のロールが作成されている
- 信頼関係が適切に設定されている
- ロール名が命名規則に従っている

---

### Task 8: IAMポリシーの定義

#### ✅ 確認項目
- [ ] ポリシー定義確認

```bash
# ポリシー定義ファイルの確認
cat terraform/modules/iam/main.tf | grep -A 20 "resource.*aws_iam_policy"
```

#### ✅ AWS Management Console での確認
1. **IAM > Policies**で作成されたポリシーを確認
2. **Policy Document**の内容確認
   - 必要な権限が含まれている
   - 過度な権限が付与されていない

#### ✅ CLI での確認
```bash
# ポリシー一覧確認
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `connect`) || contains(PolicyName, `lambda`)]'

# ポリシードキュメント確認
aws iam get-policy-version --policy-arn <policy-arn> --version-id v1
```

#### ✅ 成功基準
- 各ロールに必要なポリシーが適切にアタッチされている
- 最小権限の原則が守られている
- CloudWatch Logs出力権限が適切に設定されている

---

## Phase 4: Amazon Connect基本設定

### Task 9: Amazon Connectインスタンスモジュール作成

#### ✅ 確認項目
- [ ] Connectモジュール確認

```bash
ls -la terraform/modules/amazon_connect/
cat terraform/modules/amazon_connect/main.tf | grep "resource.*aws_connect_instance"
```

#### ✅ AWS Management Console での確認 ⭐
1. **Amazon Connect コンソール**にアクセス
   - URL: https://console.aws.amazon.com/connect/v2/
2. インスタンス作成の確認
   - インスタンス名とエイリアスの確認
   - Identity Management設定の確認
   - Inbound/Outbound calls設定の確認

#### ✅ Amazon Connect管理画面での確認 ⭐⭐
1. 作成されたConnect インスタンスのURL にアクセス
   - `https://<instance-alias>.my.connect.aws/`
2. **ダッシュボード画面**で以下を確認
   - メトリクス表示の確認
   - Real-time metricsの表示
   - Historical reportsの表示

#### ✅ 成功基準
- Amazon Connectインスタンスが正常に作成されている
- 管理画面にアクセスできる
- 基本設定が適用されている

---

### Task 10: コンタクトフロー定義

#### ✅ 確認項目
- [ ] コンタクトフローファイル確認

```bash
ls -la terraform/contact_flows/
cat terraform/contact_flows/basic_flow.json | jq . # JSON形式の確認
```

#### ✅ Amazon Connect管理画面での確認 ⭐⭐
1. Connect管理画面にログイン
2. **Routing > Contact flows**にアクセス
3. 基本フローの確認
   - Welcome messageが設定されている
   - フロー構成が論理的に構成されている
4. **フロー設計画面**での確認
   - ブロックの接続が正しい
   - エラーハンドリングが設定されている

#### ✅ 動作確認（電話テスト） ⭐⭐⭐
```bash
# CLI経由でのテスト実行（オプション）
aws connect start-outbound-voice-contact \
    --destination-phone-number "+815012345678" \
    --contact-flow-id <contact-flow-id> \
    --instance-id <instance-id>
```

#### ✅ 成功基準
- basic_flow.jsonが適切なJSON形式
- Connect管理画面でフローが表示される
- フローの論理構成が正しい

---

### Task 11: キューとルーティングプロファイル

#### ✅ Amazon Connect管理画面での確認 ⭐⭐
1. **Routing > Queues**での確認
   - Basic Queueが作成されている
   - キュー設定（時間、優先度）が適切
2. **Users > Routing profiles**での確認
   - Default Routing Profileが作成されている
   - キューとの紐付けが正しい
3. **Queue management**画面での確認
   - リアルタイムでのキュー状態表示
   - エージェント割り当て状況

#### ✅ 成功基準
- キューとルーティングプロファイルの紐付けが正しい
- 管理画面でキュー状況が確認できる
- 優先度設定が適切

---

### Task 12: 電話番号の設定

#### ✅ Amazon Connect管理画面での確認 ⭐⭐
1. **Channels > Phone numbers**での確認
   - DID番号が取得されている
   - コンタクトフローとの紐付け確認
2. **Phone number management**での確認
   - 国家・地域の設定
   - 番号タイプの確認（DID/Toll-free）

#### ✅ 実際の電話テスト ⭐⭐⭐
1. 設定された電話番号に実際に電話をかける
2. コンタクトフローが正常に動作することを確認
3. Welcome messageが再生される
4. 適切なキューにルーティングされる

#### ✅ 成功基準
- 電話番号が正常に取得されている
- 実際に電話がつながる
- コンタクトフローが動作する

---

## Phase 5: Lambda統合

### Task 13: Lambda関数モジュール作成

#### ✅ 確認項目
- [ ] Lambdaモジュール確認

```bash
ls -la terraform/modules/lambda/
cat terraform/modules/lambda/main.tf | grep "resource.*aws_lambda_function"
```

#### ✅ AWS Management Console での確認
1. **Lambda > Functions**での確認
   - Connect用Lambda関数の作成確認
   - Runtime設定（Node.js等）の確認
   - Memory/Timeout設定の確認

#### ✅ Lambda関数テスト ⭐
1. Lambda コンソールでの**Test**実行
2. サンプルConnectイベントでのテスト
3. CloudWatch Logsでの実行ログ確認

#### ✅ 成功基準
- Lambda関数が正常に作成されている
- 基本的なテストが通る
- 適切なIAMロールがアタッチされている

---

### Task 14: Lambda関数コードの作成

#### ✅ 確認項目
- [ ] ソースコード確認

```bash
ls -la src/lambda/connect_handler/
cat src/lambda/connect_handler/index.js
```

- [ ] コード品質確認

```bash
# Node.jsの場合
cd src/lambda/connect_handler/
node -c index.js  # Syntax check
npm test  # テストがある場合
```

#### ✅ Lambda関数での動作確認 ⭐
1. **Test**タブでサンプルConnectイベント作成
2. 関数実行結果の確認
3. **Monitor**タブでのメトリクス確認
4. **CloudWatch Logs**での詳細ログ確認

#### ✅ 成功基準
- JavaScriptコードにSyntaxエラーがない
- Connect属性を正しく処理できる
- エラーハンドリングが適切

---

### Task 15: Lambda権限設定

#### ✅ 確認項目
- [ ] Lambda権限設定確認

```bash
# Terraformコードでの権限確認
cat terraform/modules/lambda/main.tf | grep -A 10 "aws_lambda_permission"
```

#### ✅ AWS Management Console での確認
1. **Lambda > Configuration > Permissions**
   - Amazon Connect からの invoke 権限確認
   - CloudWatch Logs への出力権限確認
2. **Amazon Connect > Contact flows**
   - Lambda関数の invoke 設定確認

#### ✅ 統合テスト ⭐⭐
1. Amazon Connect の Contact Flow 内でLambda関数を呼び出し
2. 電話をかけて Lambda 関数が実行されることを確認
3. CloudWatch Logs で実行ログの確認

#### ✅ 成功基準
- Connect → Lambda の呼び出しが成功する
- Lambda実行ログがCloudWatchに出力される
- 権限エラーが発生しない

---

## Phase 6: ログ・監視設定

### Task 16: CloudWatch Logsモジュール作成

#### ✅ 確認項目
- [ ] CloudWatchログモジュール確認

```bash
ls -la terraform/modules/cloudwatch/
cat terraform/modules/cloudwatch/main.tf | grep "aws_cloudwatch_log_group"
```

#### ✅ AWS Management Console での確認
1. **CloudWatch > Log groups**
   - Amazon Connect用ロググループの存在確認
   - Lambda用ロググループの存在確認
   - Retention期間の設定確認

#### ✅ ログ出力確認 ⭐
1. Amazon Connect でコール実行
2. Lambda関数実行
3. 各ロググループにログが出力されることを確認

#### ✅ 成功基準
- 適切なロググループが作成されている
- ログ保持期間が適切に設定されている
- 実際にログが出力される

---

### Task 17: CloudWatch Metricsとアラーム

#### ✅ AWS Management Console での確認
1. **CloudWatch > Alarms**
   - 通話量監視アラームの確認
   - Lambda実行エラーアラームの確認
   - Connect接続エラーアラームの確認
2. **CloudWatch > Metrics**
   - Connect メトリクスの表示確認
   - Lambda メトリクスの表示確認

#### ✅ アラーム動作テスト ⭐⭐
1. 意図的にエラー状況を発生させる（Lambda関数でエラー発生等）
2. アラームが適切に発火することを確認
3. SNS通知（設定されている場合）の確認

#### ✅ 成功基準
- 必要なメトリクスが監視されている
- アラームが適切に動作する
- しきい値が適切に設定されている

---

## Phase 7: セキュリティ設定

### Task 18: KMS暗号化設定

#### ✅ 確認項目
- [ ] KMSモジュール確認

```bash
ls -la terraform/modules/kms/
cat terraform/modules/kms/main.tf | grep "aws_kms_key"
```

#### ✅ AWS Management Console での確認
1. **KMS > Customer managed keys**
   - カスタマー管理キーの作成確認
   - Key Policyの設定確認
   - エイリアス設定の確認

#### ✅ CLI での確認
```bash
# KMSキー一覧確認
aws kms list-keys

# キー詳細確認
aws kms describe-key --key-id <key-id>

# キーポリシー確認
aws kms get-key-policy --key-id <key-id> --policy-name default
```

#### ✅ 成功基準
- KMSキーが適切に作成されている
- キーポリシーが正しく設定されている
- 適切なサービスからのアクセスが許可されている

---

### Task 19: Secrets Manager設定

#### ✅ AWS Management Console での確認
1. **Secrets Manager > Secrets**
   - シークレットの作成確認
   - 暗号化設定の確認
2. **Lambda > Configuration > Environment variables**
   - Secrets Manager参照設定の確認

#### ✅ CLI での確認
```bash
# シークレット一覧確認
aws secretsmanager list-secrets

# シークレット値確認（権限がある場合）
aws secretsmanager get-secret-value --secret-id <secret-id>
```

#### ✅ 動作確認 ⭐
1. Lambda関数からSecrets Manager経由でのシークレット取得テスト
2. 暗号化されたシークレットの復号化確認

#### ✅ 成功基準
- シークレットが適切に暗号化されて保存されている
- Lambda関数からシークレット取得ができる
- 不要なアクセス権限が付与されていない

---

## Phase 8: デプロイメント・自動化

### Task 20: 環境別設定ファイル

#### ✅ 確認項目
- [ ] 環境別設定確認

```bash
ls -la terraform/environments/dev/
cat terraform/environments/dev/terraform.tfvars
```

- [ ] 設定値検証

```bash
cd terraform/environments/dev/
terraform plan -var-file="terraform.tfvars"
```

#### ✅ 成功基準
- 環境固有の設定値が適切
- terraform plan でエラーが発生しない
- 命名規則が環境に応じて設定されている

---

### Task 21: デプロイスクリプト作成

#### ✅ 確認項目
- [ ] スクリプト確認

```bash
ls -la scripts/deploy.sh
cat scripts/deploy.sh
chmod +x scripts/deploy.sh  # 実行権限確認
```

#### ✅ スクリプト動作テスト ⭐
```bash
# Dry-run モードでの実行（実際のリソースは作成しない）
./scripts/deploy.sh --dry-run

# エラーハンドリングのテスト
# 意図的にエラー状況を作りスクリプトの挙動確認
```

#### ✅ 成功基準
- スクリプトが正常に実行される
- エラーハンドリングが適切
- ログ出力が適切

---

### Task 22: CI/CD設定（GitHub Actions）

#### ✅ 確認項目
- [ ] GitHub Actions設定確認

```bash
ls -la .github/workflows/
cat .github/workflows/terraform.yml
```

#### ✅ GitHub Actions動作確認 ⭐⭐
1. **GitHub Repository > Actions**タブでの確認
2. プルリクエスト作成時のTerraform Plan実行確認
3. Main branchマージ時のTerraform Apply実行確認
4. ワークフロー実行ログの確認

#### ✅ AWS認証確認
1. GitHub ActionsのSecrets設定確認
2. OIDC認証設定（推奨）またはアクセスキー設定の確認
3. 実際のAWSリソースアクセス確認

#### ✅ 成功基準
- CI/CDワークフローが正常に動作する
- Terraform Plan/Applyが自動実行される
- セキュアなAWS認証が設定されている

---

### Task 23: 設定値検証とテスト

#### ✅ 確認項目
- [ ] テストスクリプト確認

```bash
ls -la scripts/test_connection.sh
cat scripts/test_connection.sh
chmod +x scripts/test_connection.sh
```

#### ✅ 統合テスト実行 ⭐⭐⭐
```bash
# 接続テスト実行
./scripts/test_connection.sh

# 期待される結果:
# - Amazon Connect インスタンス接続成功
# - Lambda関数実行成功
# - コンタクトフロー動作確認成功
```

#### ✅ エンドツーエンドテスト ⭐⭐⭐
1. **実際の電話テスト**
   - 設定した電話番号に発信
   - Welcome message再生確認
   - Lambda関数呼び出し確認
   - キューへの適切なルーティング確認

2. **AWS Console での確認**
   - Real-time metrics でのコール状況確認
   - CloudWatch Logs でのログ確認
   - CloudWatch Metrics でのメトリクス確認

#### ✅ 成功基準
- すべてのコンポーネントが連携して動作する
- エンドツーエンドテストがパスする
- 実際の電話処理が正常に動作する

---

### Task 24: ドキュメント作成

#### ✅ 確認項目
- [ ] ドキュメントファイル確認

```bash
ls -la docs/
cat docs/deployment.md
cat docs/troubleshooting.md
cat docs/architecture.md
cat README.md
```

#### ✅ ドキュメント品質確認
1. **deployment.md**
   - デプロイ手順が明確
   - 前提条件が記載されている
   - トラブルシューティング情報が含まれている

2. **architecture.md**
   - システム構成図が含まれている
   - コンポーネント間の関係が明確
   - セキュリティ考慮事項が記載されている

3. **README.md**
   - プロジェクト概要が分かりやすい
   - セットアップ手順が明確
   - 使用方法が記載されている

#### ✅ 成功基準
- ドキュメントが完備されている
- 第三者がドキュメントのみで作業できる
- トラブルシューティング情報が充実している

---

### Task 25: クリーンアップスクリプト作成

#### ✅ 確認項目
- [ ] クリーンアップスクリプト確認

```bash
ls -la scripts/cleanup.sh
cat scripts/cleanup.sh
chmod +x scripts/cleanup.sh
```

#### ✅ スクリプト動作テスト ⭐
```bash
# Dry-run モードでのクリーンアップテスト
./scripts/cleanup.sh --dry-run

# 実際のクリーンアップ実行（注意: 本当にリソースが削除される）
# ./scripts/cleanup.sh --confirm
```

#### ✅ 手動クリーンアップ確認
```bash
# Terraform destroy での確認
cd terraform/
terraform plan -destroy
terraform destroy -auto-approve  # 注意: 実際にリソースが削除される
```

#### ✅ 成功基準
- すべてのリソースが適切に削除される
- S3バケット等の手動削除項目が考慮されている
- 削除確認プロンプトが適切

---

## 特別な UI 確認ポイント

### Amazon Connect 管理画面での重要確認事項 ⭐⭐⭐

#### 1. ダッシュボード画面
- **URL**: `https://<instance-alias>.my.connect.aws/`
- **確認項目**: 
  - Real-time metrics の表示
  - Agent activity の状況
  - Queue performance の表示

#### 2. Contact Flow デザイナー
- **ナビゲーション**: Routing > Contact flows > 作成したフロー
- **確認項目**:
  - ブロック間の接続線が正しく描画されている
  - 各ブロックの設定が保存されている
  - Preview機能でのフロー確認

#### 3. Real-time Metrics
- **ナビゲーション**: Analytics > Real-time metrics
- **確認項目**:
  - Queue metrics の表示
  - Agent metrics の表示
  - Contact metrics の表示

#### 4. Historical Reports
- **ナビゲーション**: Analytics > Historical reports
- **確認項目**:
  - Contact search の動作
  - Report generation の動作
  - データの出力確認

### AWS Management Console での重要確認事項

#### 1. CloudWatch ダッシュボード
- **URL**: https://console.aws.amazon.com/cloudwatch/
- **確認項目**:
  - Amazon Connect メトリクス表示
  - Lambda 関数メトリクス表示
  - カスタムメトリクス表示

#### 2. Lambda 関数テストコンソール
- **ナビゲーション**: Lambda > Functions > 関数名 > Test
- **確認項目**:
  - テストイベントの設定
  - 実行結果の表示
  - ログ出力の確認

---

## 全体確認チェックリスト

### 最終統合テスト ⭐⭐⭐

#### Phase別動作確認
- [ ] **Phase 1-2**: インフラ基盤が構築されている
- [ ] **Phase 3**: IAM権限が適切に設定されている
- [ ] **Phase 4**: Amazon Connect が完全に動作する
- [ ] **Phase 5**: Lambda統合が正常に動作する
- [ ] **Phase 6**: ログ・監視が機能している
- [ ] **Phase 7**: セキュリティ設定が適用されている
- [ ] **Phase 8**: CI/CD・自動化が動作している

#### エンドツーエンドシナリオ
1. **シナリオ1: 通常のコール処理**
   - [ ] 電話番号への着信
   - [ ] Welcome message 再生
   - [ ] Lambda関数呼び出し
   - [ ] キューへのルーティング
   - [ ] CloudWatchへのログ出力

2. **シナリオ2: エラー処理**
   - [ ] Lambda関数エラー時のハンドリング
   - [ ] CloudWatch アラーム発火
   - [ ] エラーログの適切な出力

3. **シナリオ3: 監視・アラート**
   - [ ] メトリクス収集の動作
   - [ ] しきい値超過時のアラート
   - [ ] ダッシュボードでの可視化

---

## トラブルシューティングガイド

### よくある確認ポイント

#### 1. 権限関連
```bash
# IAM ロール・ポリシーの確認
aws iam get-role --role-name <role-name>
aws sts get-caller-identity  # 現在の実行ユーザー確認
```

#### 2. ネットワーク関連
```bash
# セキュリティグループ確認
aws ec2 describe-security-groups --group-names <group-name>

# VPC 設定確認
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

#### 3. Amazon Connect 関連
```bash
# Connect インスタンス確認
aws connect list-instances

# Contact Flow 確認
aws connect list-contact-flows --instance-id <instance-id>
```

#### 4. Lambda 関連
```bash
# Lambda 関数確認
aws lambda list-functions

# Lambda 実行ログ確認
aws logs describe-log-groups
aws logs get-log-events --log-group-name /aws/lambda/<function-name>
```

### UI確認時の注意点

1. **ブラウザキャッシュ**: 設定変更後は強制リロード（Ctrl+F5）を実行
2. **タイムゾーン**: メトリクス確認時は適切なタイムゾーン設定を確認
3. **権限**: Amazon Connect管理画面アクセスには適切なIAMユーザー/ロールが必要
4. **リージョン**: AWSコンソールで正しいリージョン（ap-northeast-1）が選択されているか確認

---

## まとめ

この確認チェックリストを使用することで、Task.mdで定義された各タスクが正確に実装されていることを体系的に検証できます。

- **✅**: 基本的な確認項目
- **⭐**: UI/Management Console での確認
- **⭐⭐**: 統合テスト・動作確認
- **⭐⭐⭐**: エンドツーエンドテスト・実機確認

各段階で適切な確認を行い、次のフェーズに進む前に前のフェーズの動作が完全に検証されていることを確認してください。
