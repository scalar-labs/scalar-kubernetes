# AWS での Scalar DL Auditor 導入方法

Scalar DL Auditor は、ビザンチン故障を検知するために Ledger と同一の情報を管理するコンポーネントです。  
本ガイドでは、Scalar DL Auditor を Amazon Web Services (AWS) のマネージド Kubernetes サービス (EKS) 上に手動でデプロイする方法を説明します。

## 作成するコンポーネント

このガイドでは、以下のコンポーネントを作成します。

* NAT ゲートウェイを持つ VPC
    * Scalar DL のコンテナイメージは GitHub Packages から取得するため、EKS のワーカーノードからインターネット (GitHub) へ通信する必要があります。そのため、EKS ワーカーノードをプライベートサブネット上に作成する場合は、NAT ゲートウェイが必要です。
    * EKS のワーカーノードをパブリックサブネット上に作成する (ワーカーノードから直接インターネット上に通信する) 場合、NAT ゲートウェイは不要です。
* Scalar DL 用のノードグループを持つ EKS クラスタ
    * 最低 1 つのノードグループ (Scalar DL 専用のノードグループ) を作成します。
    * 他のコンテナ (アプリケーションコンテナ等) を同一クラスタ内にデプロイする場合は、アプリケーション用のノードグループを必要に応じて別途作成します。
* データベース
    * Scalar DL が対応しているデータベースが必要です。
* パブリック IP を持つ踏み台サーバー
    * EKS 用の VPC 内にパブリック IP を持つ踏み台サーバーを作成します。
    * 以下のように、EKS クラスタの各リソースにパブリックなアクセスが実施できる場合は、必須ではありません。
        * EKS の API エンドポイントがパブリックに設定されている。
        * 各ワーカーノードがパブリックサブネットに配置されている。
    * API エンドポイントやワーカーノードがプライベートサブネット上に配置される場合は、それらのリソースにアクセスするための踏み台サーバーが必要です。
        * API エンドポイントのアクセスコントロールについては、[AWS 公式ドキュメント "Amazon EKS cluster endpoint access control"](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) を参照してください。
* Amazon CloudWatch
    * Scalar DL コンテナのログやメトリクスの監視に利用します。


## 前提条件

* Auditor を利用する際に必要な設定 (`ledgerProofEnabled` 及び `ledgerAuditorEnabled`) を有効にした Scalar DL Ledger の導入が完了している必要があります。

## Step 1. Auditor 用の環境構築

Scalar DL Auditor を利用する場合、1つの管理ドメインに対して全ての権限を持つ管理者はあらゆる悪意のある操作を行うことができてしまうため、本番環境では Ledger 用とは異なる管理ドメインに Auditor を導入することが強く推奨されます。しかし、本ガイドでは、説明を容易にするため、Ledger と同じ管理ドメイン (つまり、同じサブスクリプション上の別の EKS クラスタ) に Auditor を導入します。  

Ledger 環境の作成手順を参考に、別の管理ドメインのネットワーク (VPC)、Auditor で利用するデータベース、EKS クラスタを構築し、Auditor を導入する必要があります。

### 要件

* Ledger 用の EKS クラスタが利用している VPC、及びクライアント/アプリケーションが利用している VPC が使用していない IP アドレスレンジで、Auditor 用のEKS クラスタを構築する VPC を作成する必要があります。
* Ledger / Auditor / アプリケーションの間で通信ができるようにネットワーク (VPC ピアリング/ルートテーブル/セキュリティグループ等) を構築する必要があります。
* Auditor が利用するデータベースを用意する必要があります。

### 推奨事項

* Ledger と Auditor は別々の管理ドメインに配置することが強く推奨されます。
* Ledger をデプロイしている EKS クラスタとは別に、Auditor 用の EKS クラスタを用意することが強く推奨されます。

### 手順

* [Deploy Scalar DL on AWS](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/JpManualDeploymentGuideScalarDLOnAWS.md) の Step 1 ～ Step 3 に従い、Scalar DL Auditor 用の環境 (EKS クラスタ) を構築してください。

## Step 2. ネットワーク設定

Ledger、Auditor、及びクライアントアプリケーションを異なる VPC 上の EKS クラスタやサーバーにデプロイする場合は、各コンポーネント間で必要な通信が実施できる必要があります。  

このセクションでは、各コンポーネント間の通信に必要な設定について記載します。  

### 要件

* VPC 間の通信を可能にするため、Ledger、Auditor、クライアントの VPC 間でピアリングを作成する必要があります。
* VPC 間の通信を可能にするため、Ledger、Auditor、クライアントのルートテーブルを更新する必要があります。
* VPC 間の通信を可能にするため、Ledger、Auditor、クライアントのネットワーク ACL / セキュリティグループを更新する必要があります。

### 推奨事項

* Ledger および Auditor のネットワーク ACL やセキュリティグループ等を利用して、各コンポーネント間の通信を制御する (利用しない通信を制限する) ことを推奨します。

### 手順

* ※以下の内容は、クライアント/アプリケーション用の VPC を別途作成している場合を想定しています。クライアント/アプリケーションを Ledger / Auditor 用の VPC 内に構築する場合は、適宜必要な通信を許可する設定を実施してください。
* [AWS 公式ドキュメント "Create and accept VPC peering connections"](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html)　に基づき、Ledger、Auditor、クライアント の各 VPC 間で 3つのピアリング接続を作成します。
    * Ledger と Auditor 間のピアリング。
    * Ledger と クライアント間のピアリング。
    * Auditor とクライアント間のピアリング。
* [AWS 公式ドキュメント "Update your route tables for a VPC peering connection"](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html) に基づき、各 VPC ピアリング接続用のルートテーブルを更新します。
    * Ledger と Auditor 間の通信に必要なルートテーブル。
    * Ledger と クライアント間の通信に必要なルートテーブル。
    * Auditor とクライアント間の通信に必要なルートテーブル。
* ネットワーク ACL やセキュリティグループを利用し、各コンポーネント間で必要な通信を許可する設定を実施 (不要な通信を制限する設定を実施) します。
    * Scalar DL にて必要な通信は以下の通りです。
        * クライアントから Ledger 用の Envoy (NLB) への通信 (例: デフォルトでは TCP/50051 及び TCP/50052)。
        * Auditor から Ledger 用の Envoy (NLB) への通信 (例: デフォルトでは TCP/50051 及び TCP/50052)。
        * クライアントから Audior 用の Envoy (NLB) への通信 (例: デフォルトでは TCP/40051 及び TCP/40052)。
        * Ledger 用のワーカーノードからインターネット上 (GitHub Packages) への通信。
        * Auditor 用のワーカーノードからインターネット上 (GitHub Packages) への通信。
    * EKS クラスタの管理や動作の観点で、以下のような設定が必要にある場合もあるため、必要に応じて設定を実施してください。
        * 各 EKS クラスタのワーカーノードへの SSH アクセスを許可する設定。
        * Ledger 用の VPC CIDR から Ledger 用の VPC 自体への通信 (VPC 内の各ノード間の通信)。
        * Auditor 用の VPC CIDR から Auditor 用の VPC 自体への通信 (VPC 内の各ノード間の通信)。
    * ネットワーク ACL やセキュリティグループで「拒否」ルールを設定する場合は、上記各ルールについて適切な優先順位を設定してください。

## Step 3. Scalar DL Auditor のインストール

EKS クラスタを作成後、EKS クラスタに Scalar DL をデプロイします。  
ここでは、[Helm Charts](https://github.com/scalar-labs/helm-charts) を用いて EKS クラスタに Scalar DL をインストールする方法を記載します。  

### 前提条件

* [Helm Charts](https://github.com/scalar-labs/helm-charts) を利用するために、踏み台サーバーに Helm をインストールします。
    * [Helm 公式ドキュメント "Installing Helm"](https://helm.sh/docs/intro/install/) に基づいて、helm コマンドをインストールします。
    * Scalar DL の Helm Charts を利用するためには、バージョン 3.5 以降の Helm が必要です。
* [GitHub 公式ドキュメント](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)に基づいて、GitHub Personal Access Token (PAT) を作成します。
    * GitHub Packages から `scalar-auditor` と `scalardl-schema-loader` のコンテナイメージを取得するため、PAT には `read:packages` スコープを設定する必要があります。

### 要件

* GitHub Packages から `scalar-auditor` と `scalardl-schema-loader` のコンテナイメージを取得する権限が必要です。
* Helm Charts 用の `scalardl-audit-custom-values.yaml` ファイルでデータベースへ接続するためのプロパティを設定する必要があります。
* Scalar DL Auditor を利用する場合は、`auditor-keys` という名前の Secret リソース (Auditor 用の秘密鍵と公開鍵を含む Secret リソース) を作成する必要があります。

### 推奨事項

* `scalardl-audit-custom-values.yaml` ファイルで設定されている Auditor と Envoy の Pod のレプリカ数 (replicaCount の設定値) を、Scalar DL 用のノードグループ内のノード数と等しくすることを推奨します。
    * デフォルトで提供されている `scalardl-audit-custom-values.yaml` では `podAntiAffinity` が設定されているため、Scalar DL 用のノードグループ内のノード 1つにつき、Auditor と Envoy が 1つ (1組) のみ動作します。
    * 1つのノード上で複数組の Auditor と Envoy を動作させる場合は、 `scalardl-audit-custom-values.yaml` 内の `podAntiAffinity` の設定を変更してください。

### 手順

以下の手順で EKS 上に Scalar DL Auditor をインストールします。以下の手順は踏み台サーバー上 (EKS の API エンドポイントにアクセス可能な環境上) で実行します。

1. [scalar-kubernetes リポジトリ](https://github.com/scalar-labs/scalar-kubernetes/tree/master/conf)から、以下の Scalar DL Auditor 用の設定ファイルをダウンロードします。なお、これらのファイルは将来的にバージョンアップされる可能性があるため、必要に応じて適切なバージョンを使用するようにブランチを変更してください。
    * scalardl-audit-custom-values.yaml
    * schema-loading-custom-values.yaml

1. [Configure Scalar DL](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/ConfigureScalarDL.md) の内容を参考に `scalardl-audit-custom-values.yaml` 及び `schema-loading-custom-values.yaml` の内容 (データベースへの接続設定等) を環境に合わせて変更してください。
    * `schema-loading-custom-values.yaml` の `schemaType` には `auditor` を設定します。
    * `scalardl-audit-custom-values.yaml` の `auditorLedgerHost` には Ledger 用の Envoy Service の EXTERNAL-IP に表示されている値 (NLB の FQDN) を設定します。
        * EXTERNAL-IP の値は Ledger 側の EKS クラスタに対して `kubectl service` を実行することで確認可能です。

1. GitHub のコンテナレジストリから Scalar DL Auditor のイメージを取得するために必要な Secret リソース `reg-docker-secrets` を作成します。
   ```console
   kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
   ```

1. Ledger に送信するリクエストへの署名および Ledger から受け取ったリクエストの検証を実施する際に利用する Auditor の秘密鍵および公開鍵を含む Secret リソース `auditor-keys` を作成します。
   ```console
   kubectl create secret generic auditor-keys --from-file=certificate=auditor-cert.pem --from-file=private-key=auditor-key.pem 
   ```

1. helm コマンドを実行し、EKS に Scalar DL Auditor をデプロイします。
   ```console
   # Add Helm charts
   helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
   
   # List the Scalar charts.
   helm search repo scalar-labs -l
   
   # Load Schema for Scalar DL Auditor install with a release name `load-audit-schema`
   helm upgrade --version <chart version> --install load-audit-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml --set schemaLoading.schemaType=auditor
  
   # Install Scalar DL Auditor with a release name `my-release-scalar-audit`
   helm upgrade --version <chart version> --install my-release-scalar-audit scalar-labs/scalardl-audit --namespace default -f scalardl-audit-custom-values.yaml
   ```

   * 注意
        * 同じコマンドで Pod のアップグレードが可能です。
        * リリース名 `load-audit-schema` 及び `my-release-scalar-audit` は任意の値に変更可能です。
        * チャートバージョン `<chart version>` に指定する値は `helm search repo scalar-labs -l` の出力から確認してください。
        * `helm ls -a` コマンドを使用すると、現在インストールされているリリースの一覧を表示することができます。
        * Scalar DL Auditor をインストールする前に `kubectl get pods` で `schema-loading` の処理が完了したこと (Pod の STATUS が Complete になること) を確認する必要があります。
        * Scalar DL Auditor の Pod の設定を Helm で管理する方法については、[Maintain Scalar DL Pods](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/MaintainPods.md) を参照してください。
        * クライアントアプリケーションを起動する前に、Ledger と Auditor の証明書を相互に登録する必要があります。
            * Ledger の公開鍵 (証明書) を Auditor に、Auditor の公開鍵 (証明書) を Ledger にそれぞれ登録する必要があります。

## Step 4. クラスタを監視する

[Deploy Scalar DL on AWS](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/JpManualDeploymentGuideScalarDLOnAWS.md#step-6-monitor-the-cluster) の Step 6 を参照し、EKS クラスタや各 Pod の監視設定を実施します。

## Step 5. Scalar DL Auditor のインストールを確認するためのチェックリスト

Scalar DL Auditor のインストール完了後、インストールが正常に完了したことを確認します。ここでは、インストールの確認について説明します。

### Scalar DL Auditor のデプロイメントを確認する

* Auditor 用のスキーマ (テーブル) が、利用するデータベースに正しく作成されていることを確認します。
    * データベース上に以下のテーブルが作成されます。
      ```console
      auditor.asset
      auditor.asset_lock
      auditor.certificate
      auditor.contract
      auditor.contract_class
      auditor.request_proof
      scalardb.metadata
      ```
    * 注意
        * Cassandra を利用する場合、`scalardb.metadata` は作成されません。

* Kubernetes 上に Pod と Service リソースが正常にデプロイされているかどうかは、踏み台サーバー上で `kubectl get pods,services -o wide` コマンドを実行することで確認できます。
    * すべての Auditor と Envoy の Pod のステータスが `Running` であることを確認します。
    * Scalar DL Auditor Envoy サービスの `EXTERNAL-IP` が作成されていることを確認します。
   ```console
   $ kubectl get pod,services -o wide
   NAME                                                                 READY   STATUS      RESTARTS   AGE     IP            NODE                                        NOMINATED NODE   READINESS GATES
   pod/load-audit-schema-schema-loading-776v4                           0/1     Completed   0          7m37s   10.45.3.211   ip-10-45-3-235.us-west-2.compute.internal   <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-auditor-b4dbcdd65-d46jw   1/1     Running     0          4m4s    10.45.3.119   ip-10-45-3-235.us-west-2.compute.internal   <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-auditor-b4dbcdd65-qsrzn   1/1     Running     0          4m4s    10.45.1.71    ip-10-45-1-72.us-west-2.compute.internal    <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-auditor-b4dbcdd65-tdcfb   1/1     Running     0          4m4s    10.45.2.235   ip-10-45-2-37.us-west-2.compute.internal    <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-ffppb    1/1     Running     0          4m4s    10.45.2.228   ip-10-45-2-37.us-west-2.compute.internal    <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-s58pd    1/1     Running     0          4m4s    10.45.1.221   ip-10-45-1-72.us-west-2.compute.internal    <none>           <none>
   pod/my-release-scalar-audit-scalardl-audit-envoy-5469ccd578-wk8gk    1/1     Running     0          4m4s    10.45.3.174   ip-10-45-3-235.us-west-2.compute.internal   <none>           <none>
  
   NAME                                                           TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)                           AGE    SELECTOR
   service/kubernetes                                             ClusterIP      172.20.0.1       <none>                                                                          443/TCP                           66m    <none>
   service/my-release-scalar-audit-scalardl-audit-envoy           LoadBalancer   172.20.142.214   a6114466aab584eb4a06d20b099354b6-8a342a88eaa5e752.elb.us-west-2.amazonaws.com   40051:30522/TCP,40052:30353/TCP   4m4s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
   service/my-release-scalar-audit-scalardl-audit-envoy-metrics   ClusterIP      172.20.170.78    <none>                                                                          9001/TCP                          4m4s   app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
   service/my-release-scalar-audit-scalardl-audit-headless        ClusterIP      None             <none>                                                                          50051/TCP,50053/TCP,50052/TCP     4m4s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
   service/my-release-scalar-audit-scalardl-audit-metrics         ClusterIP      172.20.221.28    <none>                                                                          8080/TCP                          4m4s   app.kubernetes.io/app=auditor,app.kubernetes.io/instance=my-release-scalar-audit,app.kubernetes.io/name=scalardl-audit
   ```
