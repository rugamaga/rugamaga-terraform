# rugamaga-terraform

## これは何？

rugamaga.net(PRD環境)とrugamaga.dev(DEV環境)を構築するためのterraformリポジトリ

## 使い方

### 初回セットアップ

#### 1. GCPプロジェクトを準備する

セットアップとして3つのGCPプロジェクトを必要とします。

- `rugamaga`: prd, dev共通のサービス(terraform stateやコンテナレジストリのためのGCS,GCR)を保持する
- `rugamaga-prd`: PRD環境用
- `rugamaga-dev`: DEV環境用

もしSTG環境などを更に増やしたい場合は
`.circleci/config.yml` をDEVを参考に書き換えてください。

#### 2. GoogleDNSでドメインを2つ取得する

GoogleDNS用に2つドメインを取得し、
`variables-prd.tf` や `variables-dev.tf` の
`domain_name` として記入しておいてください。

#### 3. IAMでサービスアカウントの発行

`rugamaga-prd` および `rugamaga-dev` において
terraform用の編集者ロール(Editor role)なサービスアカウントを発行してください。
また、これらのロールには、

これらのサービスアカウントのJSONキーは

- `.credentials/terraform@rugamaga-prd.json`
- `.credentials/terraform@rugamaga-dev.json`

としてローカルでは記録してください。(gitにはコミットしません)
後ほどCircleCIでENVとしてこれらのJSONを記録します。

#### 4. `rugamaga`プロジェクトでGCS bucketを作成する

`rugamaga`プロジェクトに対して新しいGCS bucketを作成し
`main.tf` で指定されている `gcs` backend の `bucket` に記載してください。
このバケットはterraformのstateを記録するために利用されます。

#### 5. 各サービスアカウントにバケット編集権限を与える

作成したGCS bucketにおいて

- `.credentials/terraform@rugamaga-prd.json`
- `.credentials/terraform@rugamaga-dev.json`

の2つのサービスアカウントに対してGCSのバケット編集権限を付与してください。
(プロジェクトを跨いでいても利用することができます)

#### 5. 環境を定義する

docker-composeによりterraform環境を立ててenvを定義しましょう

```
docker-compose run terraform init
docker-compose run terraform workspace new prd
docker-compose run terraform workspace new dev
```

#### 6. CircleCIセットアップ

CircleCIの環境変数を設定します。

- `PRD_GCLOUD_SERVICE_KEY`: `.credentials/terraform@rugamaga-prd.json` の中身をすべて貼り付ける
- `DEV_GCLOUD_SERVICE_KEY`: `.credentials/terraform@rugamaga-dev.json` の中身をすべて貼り付ける

環境を増やす場合はこのキーを増やすことで行うことができます。

### ローカル実行

docker-composeによりterraform環境を立ててローカルで実行できます。

```
# initする
docker-compose run terraform init

# workspaceを選択する
docker-compose run terraform workspace select prd # prd環境の場合
docker-compose run terraform workspace select dev # dev環境の場合

# planする
docker-compose run terraform plan

# applyする
docker-compose run terraform apply
```

### CircleCI

#### Planする

Planはgit pushを行うたびに自動的に行われます。

#### Releaseする

masterブランチが進むと自動的にDEV環境が更新されます。

PRD環境へのリリースは `PRD/vN.N.N` というタグを張ってください。
vN.N.Nは通常のセマンティックバージョニングに従ってください。

一般にXXX環境へのリリースは `XXX/vN.N.N` というタグを増やす形で行いましょう。
