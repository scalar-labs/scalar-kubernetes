# AWS での Scalar DL 導入方法

Scalar DL は、データベースに依存しない分散型台帳ミドルウェアで、Docker コンテナとして提供されています。  
様々なプラットフォームに展開可能ですが、高い可用性と拡張性、保守性を実現するために、本番環境ではマネージドサービス上に展開することが推奨されています。  

本ガイドでは、Scalar DL Ledger を Amazon Web Services (AWS) のマネージド Kubernetes サービス (EKS) 上に手動でデプロイする方法を説明します。

* Scalar DL Ledger は、改ざん検知可能なレコード (アセット) をデータベースに格納するコンポーネントです。詳細は、[Getting Started with Scalar DL](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started.md) のガイドを参照してください。
* Scalar DL Auditor は、ビザンチン故障を検知するために Ledger と同一の情報を管理するコンポーネントです。詳細は、[Getting Started with Scalar DL Auditor](https://github.com/scalar-labs/scalardl/blob/master/docs/getting-started-auditor.md) のガイドを参照してください。また、AWS での Scalar DL Auditor の導入方法については[こちらのドキュメント](./docs/JpManualDeploymentGuideScalarDLAuditorOnAWS.md)を参照してください。

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

## Step 1. ネットワーク (VPC) を作成

組織やアプリケーションの基準に基づいてセキュアなネットワーク (VPC) を作成してください。  
Scalar DL は、アプリケーションの機密性の高いデータを扱うため、本番環境では安全性の高いネットワークを構築することが推奨されます。  
ここでは、Scalar DL をデプロイする際に必要な設定について記載します。  

### 要件

* Scalar DL のコンテナは GitHub Packages から取得するため、EKS のワーカーノードからインターネット (GitHub) へ通信する必要があります。ワーカーノードをプライベートサブネット上に作成する場合、Scalar DL 用の EKS で利用する VPC には NAT ゲートウェイを作成する必要があります。
* Scalar DL Auditor を利用する場合、「Scalar DL Ledger 用の EKS が構築される VPC」と「Scalar DL Auditor 用の EKS が構築される VPC」を VPC ピアリングで接続する必要があります。そのため、2つの VPC の CIDR の範囲が被らないようにする必要があります。
    * クライアント/アプリケーションを Ledger / Auditor と異なる VPC 上にデプロイする場合は、クライアント/アプリケーション用の VPC の CIDR の範囲も被らないようにする必要があります。
* その他、EKS クラスタ用の VPC に必要な要件 (EKS クラスタ自体の VPC に関する要件) については、[AWS 公式ドキュメント "Cluster VPC and subnet considerations"](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html) を参照してください。

### 推奨事項

* 本番用の EKS クラスタには、プライベートサブネットを利用することを推奨します。  
* プライベートサブネット上の EKS クラスタを管理するために、踏み台サーバーを作成することを推奨します。  
* より高い可用性を持つ EKS クラスタを作成するために、3つのアベイラビリティゾーンに 3つのサブネットを作成することを推奨します。
* EKS クラスタがスケーリング後も問題なく動作するように、最低でも `/24` のプレフィックスを持つサブネットを作成することを推奨します。

### 手順

* [AWS 公式ドキュメント "Creating a VPC for your Amazon EKS cluster"](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html) に基づいて、上記の要件と推奨事項を満たした VPC を作成してください。
    * ※eksctl を利用してクラスタを作成する場合は、eksctl 内の処理で VPC を作成することも可能であるため、個別での VPC 作成は必須ではありません。構築する環境/構築方法に合わせて VPC の作成方法を選択してください。

## Step 2. データベースの構築

このセクションでは、Scalar DL Ledger 用のデータベースを作成します。

### 要件

* Scalar DL が対応しているデータベースが必要です。

### 手順

* [Set up a database](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/SetupDatabase.md) に従って、Scalar DL Ledger 用のデータベースを構築してください。

## Step 3. EKS の構築

このセクションでは、EKS クラスタのコントロールプレーンと、Scalar DL (Ledger 及び Envoy) をデプロイするノードグループ を作成します。  
Scalar DL 以外のアプリケーション等を同一クラスタ内にデプロイする場合は、アプリケーション用のノードグループを別途作成/追加してください。  

### 前提条件

* EKS 用の VPC 内にパブリック IP を持つ踏み台サーバーを作成します。
* EKS クラスタの構築に必要な各ツール (kubectl/eksctl/AWS CLI) を踏み台サーバーにインストールします。
    * 各ツールのインストール方法については [AWS 公式ドキュメント "Getting started with Amazon EKS"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) を参照してください。

### 要件

* Scalar DL を導入するためには、バージョン 1.19 以上の Kubernetes クラスターが必要です。
* Scalar DL 用のノードグループ内のノードには、Key が `agentpool`、Value が `scalardlpool` である「Label (agentpool=scalardlpool)」を設定する必要があります。
* Scalar DL 用のノードグループ内のノードには、Key が `kubernetes.io/app`、Value:Effect が `scalardlpool:NoSchedule` である「Taints (kubernetes.io/app=scalardlpool:NoSchedule)」を設定する必要があります。
    * EKS 側の制限として `kubernetes.io/app` を Key にした Taints をノードグループに設定することができないため、クラスタ構築後に `kubectl taint nodes` コマンドで各ノードに Taints を設定する必要があります。
* EKS 側のセキュリティグループや踏み台サーバー側のセキュリティグループ等の設定にて、踏み台サーバーから EKS の API エンドポイントに対する HTTPS (TCP/443) 通信を許可する必要があります。
* その他、環境 (システムのセキュリティ要件等) に応じて、ネットワーク ACL やセキュリティグループ等の機能を利用したアクセス制御を実施する必要があります。
    * EKS 関連のコンポーネントで必要な通信やセキュリティグループの設定については [AWS 公式ドキュメント "Amazon EKS security group considerations"](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) を参照してください。

### 推奨事項

* Scalar DL 用のノードグループのインスタンスタイプには `m5.xlarge` を利用することを推奨します。
* 本番環境での高可用性を確保するため、Scalar DL 用のノードグループには最低 3つのノード作成することを推奨します。
* 手動/自動で Scalar DL のコンテナをスケールする場合は、[AWS 公式ドキュメント "Autoscaling"](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html) に基づいて Cluster Autoscaler を設定し、クラスタ内のノードをスケールできるようにすることを推奨します。

### 手順

* [AWS 公式ドキュメント "Creating an Amazon EKS cluster"](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) に基づいて、上記の要件と推奨事項を満たす EKS クラスタを作成します。
* [AWS 公式ドキュメント "Creating a managed node group"](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) に基づいて、上記の要件と推奨事項を満たすマネージドノードグループを作成します。
    * 必要に応じて、Scalar DL 以外のアプリケーションをデプロイするノードグループも作成してください。
* EKS クラスタ構築後、[AWS 公式ドキュメント "Create a kubeconfig for Amazon EKS"](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) に基づいて、kubectl コマンドで API エンドポイントに接続するための認証情報 (kubeconfig) を設定します。

## Step 4. Scalar DL のインストール

EKS クラスタを作成後、EKS クラスタに Scalar DL をデプロイします。  
ここでは、[Helm Charts](https://github.com/scalar-labs/helm-charts) を用いて EKS クラスタに Scalar DL をインストールする方法を記載します。  

### 前提条件

* [Helm Charts](https://github.com/scalar-labs/helm-charts) を利用するために、踏み台サーバーに Helm をインストールします。
    * [Helm 公式ドキュメント "Installing Helm"](https://helm.sh/docs/intro/install/) に基づいて、helm コマンドをインストールします。
    * Scalar DL の Helm Charts を利用するためには、バージョン 3.5 以降の Helm が必要です。
* [GitHub 公式ドキュメント](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)に基づいて、GitHub Personal Access Token (PAT) を作成します。
    * GitHub Packages から `scalar-ledger` と `scalardl-schema-loader` のコンテナイメージを取得するため、PAT には `read:packages` スコープを設定する必要があります。

### 要件

* GitHub Packages から `scalar-ledger` と `scalardl-schema-loader` のコンテナイメージを取得する権限が必要です。
* Helm Charts 用の `scalardl-custom-values.yaml` ファイルでデータベースへ接続するためのプロパティを設定する必要があります。
* Scalar DL Auditor を導入する場合は、`scalardl-custom-values.yaml` ファイル内で Auditor の利用に必要な設定 (`ledgerProofEnabled` 及び `ledgerAuditorEnabled`) を有効にする必要があります。
* `ledgerProofEnabled` の設定を有効にする場合は、`ledger-keys` という名前の Secret リソース (Ledger 用の秘密鍵を含む Secret リソース) を作成する必要があります。

### 推奨事項

* `scalardl-custom-values.yaml` ファイルで `ledgerProofEnabled` を有効にし、 `ledger-keys` という名前の Secret リソース (Ledger 用の秘密鍵を含む Secret リソース) を作成すること (Asset Proofs を有効にすること) を推奨します。
* `scalardl-custom-values.yaml` ファイルで設定されている Ledger と Envoy の Pod のレプリカ数 (replicaCount の設定値) を、Scalar DL 用のノードグループ内のノード数と同にすることを推奨します。
    * デフォルトで提供されている `scalardl-custom-values.yaml` では `podAntiAffinity` が設定さているため、Scalar DL 用のノードグループ内のノード 1つにつき、Ledger と Envoy が 1つ (1組) のみ動作します。
    * 1つのノード上で複数組の Ledger と Envoy を動作させる場合は、 `scalardl-custom-values.yaml` 内の `podAntiAffinity` の設定を変更してください。

### 手順

以下の手順で EKS 上に Scalar DL Ledger をインストールします。以下の手順は踏み台サーバー上 (EKS の API エンドポイントにアクセス可能な環境上) で実行します。

1. [scalar-kubernetes リポジトリ](https://github.com/scalar-labs/scalar-kubernetes/tree/master/conf)から、以下の Scalar DL Ledger 用の設定ファイルをダウンロードします。なお、これらのファイルは将来的にバージョンアップされる可能性があるため、必要に応じて適切なバージョンを使用するようにブランチを変更してください。
    * scalardl-custom-values.yaml
    * schema-loading-custom-values.yaml

1. [Configure Scalar DL](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/ConfigureScalarDL.md) の内容を参考に `scalardl-custom-values.yaml` 及び `schema-loading-custom-values.yaml` の内容 (データベースへの接続設定等) を環境に合わせて変更してください。
    * `schema-loading-custom-values.yaml` の `schemaType` には `ledger` を設定します。

1. GitHub のコンテナレジストリから Scalar DL のイメージを取得するために必要な Secret リソース `reg-docker-secrets` を作成します。
   ```console
   kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
   ```

1. `scalardl-custom-values.yaml` で `ledgerProofEnabled` を有効にした場合は、Scalar DL Ledger 用の秘密鍵を含む Secret リソース `ledger-keys` 作成します。Scalar DL Auditor を利用する場合は、この設定が必須です。
   ```console
   kubectl create secret generic ledger-keys --from-file=private-key=<private key file>
   ```

1. helm コマンドを実行し、EKS に Scalar DL をデプロイします。
   ```console
   # Add Helm charts
   helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
   
   # List the Scalar charts.
   helm search repo scalar-labs -l
   
   # Load Schema for Scalar DL install with a release name `load-schema`
   helm upgrade --version <chart version> --install load-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml
   
   # Install Scalar DL with a release name `my-release-scalardl`
   helm upgrade --version <chart version> --install my-release-scalardl scalar-labs/scalardl --namespace default -f scalardl-custom-values.yaml
   ```

   * 注意
        * 同じコマンドで Pod のアップグレードが可能です。
        * リリース名 `load-schema` 及び `my-release-scalardl` は任意の値に変更可能です。
        * チャートバージョン `<chart version>` に指定する値は `helm search repo scalar-labs -l` の出力から確認してください。
        * `helm ls -a` コマンドを使用すると、現在インストールされているリリースの一覧を表示することができます。
        * Scalar DL をインストールする前に `kubectl get pods` で `schema-loading` の処理が完了したこと (Pod の STATUS が Complete になること) を確認する必要があります。
        * Scalar DL の Pod の設定を Helm で管理する方法については、[Maintain Scalar DL Pods](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/MaintainPods.md) を参照してください。

## Step 5. Scalar DL Auditor を導入する

Scalar DL Auditor は、ビザンチン故障を検知するために Ledger と同一の情報を管理するコンポーネントです。Auditor を使用すると、セキュリティの観点からは大きなメリットがありますが、追加でコストがかかります。

### 要件

* Auditor を利用する際に必要な設定 (`ledgerProofEnabled` 及び `ledgerAuditorEnabled`) を有効にした Scalar DL Ledger を導入する必要があります。

### 手順

* [Deploy Scalar DL Auditor on AWS](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/JpManualDeploymentGuideScalarDLAuditorOnAWS.md) を参照してください。

## Step 6. クラスタを監視する

本番環境で稼働しているクラスタでは、全体的な健全性とパフォーマンスを積極的に監視することが重要です。EKS を利用する場合、Container Insights を使用してパフォーマンスメトリクスを収集し、Fluent Bit を使用してクラスタのログを収集することができます。このセクションでは、EKS クラスタのモニタリングとロギングを設定する方法を説明します。

### 推奨事項

* 本番環境では、EKS のコントロールプレーンの監視を有効にすることを推奨します。
* Pod からメトリクスを収集するために、EKS クラスタに CloudWatch エージェントをデプロイすることを推奨します。
* Pod からログを収集するために、EKS クラスタに Fluent Bit をデプロイすることを推奨します。

### 要件

* EKS で Container Insights を利用する場合の要件については [AWS 公式ドキュメント "Verify prerequisites"](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html) を参照してください。
* Scalar DL 用のノードグループ内のノードには Taints が設定されているため、CloudWatch や Fluent Bit をデプロイする DaemonSet (Pod) が当該ノード上にデプロイされない可能性があります。その場合は、必要に応じて DaemonSet のマニフェスト内に Tolerations を設定してください。

### 手順

* [AWS 公式ドキュメント "Quick Start setup for Container Insights on Amazon EKS and Kubernetes"](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html) に基づいて、EKS クラスタに CloudWatch エージェントと Fluent Bit をデプロイします。

## Step 7. Scalar DL のインストールを確認するためのチェックリスト

Scalar DL のインストール完了後、インストールが正常に完了したことを確認します。ここでは、インストールの確認について説明します。

### Scalar DL のデプロイメントを確認する

* Ledger 用のスキーマ (テーブル) が、利用するデータベースに正しく作成されていることを確認します。
    * データベース上に以下のテーブルが作成されます。
      ```console
      scalar.asset
      scalar.asset_metadata
      scalar.certificate
      scalar.contract
      scalar.contract_class
      scalar.function
      scalar.tx_state
      coordinator.state
      scalardb.metadata
      ```
    * 注意
        * Cassandra を利用する場合、`scalardb.metadata` は作成されません。

* Kubernetes 上に Pod と Service リソースが正常にデプロイされているかどうかは、踏み台サーバー上で `kubectl get pods,services -o wide` コマンドを実行することで確認できます。
    * すべての Ledger と Envoy の Pod のステータスが `Running` であることを確認します。
    * Scalar DL Envoy サービスの `EXTERNAL-IP` が作成されていることを確認します。
       ```console
       kubectl get pods,services -o wide
       NAME                                              READY   STATUS      RESTARTS   AGE     IP             NODE                                          NOMINATED NODE   READINESS GATES
       pod/load-schema-schema-loading-f75q6              0/1     Completed   0          3m18s   172.20.4.158   ip-172-20-4-249.ap-south-1.compute.internal   <none>           <none>
       pod/my-release-scalardl-envoy-7598cc45dd-dqbgl    1/1     Running     0          70s     172.20.4.7     ip-172-20-4-249.ap-south-1.compute.internal   <none>           <none>
       pod/my-release-scalardl-envoy-7598cc45dd-dw4d5    1/1     Running     0          70s     172.20.4.96    ip-172-20-4-100.ap-south-1.compute.internal   <none>           <none>
       pod/my-release-scalardl-envoy-7598cc45dd-vb4mt    1/1     Running     0          70s     172.20.2.39    ip-172-20-2-74.ap-south-1.compute.internal    <none>           <none>
       pod/my-release-scalardl-ledger-654df95577-c2tzr   1/1     Running     0          70s     172.20.4.231   ip-172-20-4-249.ap-south-1.compute.internal   <none>           <none>
       pod/my-release-scalardl-ledger-654df95577-dr64g   1/1     Running     0          70s     172.20.2.26    ip-172-20-2-74.ap-south-1.compute.internal    <none>           <none>
       pod/my-release-scalardl-ledger-654df95577-hxs2t   1/1     Running     0          70s     172.20.4.166   ip-172-20-4-100.ap-south-1.compute.internal   <none>           <none>
      
       NAME                                          TYPE           CLUSTER-IP       EXTERNAL-IP                                                                      PORT(S)                           AGE     SELECTOR
       service/kubernetes                            ClusterIP      10.100.0.1       <none>                                                                           443/TCP                           3h   <none>
       service/my-release-scalardl-envoy             LoadBalancer   10.100.114.185   a2baf5324b1124db6a30238667c4be9c-a418e179c4c5b8f3.elb.ap-south-1.amazonaws.com   50051:32664/TCP,50052:30104/TCP   71s     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
       service/my-release-scalardl-envoy-metrics     ClusterIP      10.100.34.146    <none>                                                                           9001/TCP                          71s     app.kubernetes.io/app=envoy,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
       service/my-release-scalardl-ledger-headless   ClusterIP      None             <none>                                                                           50051/TCP,50053/TCP,50052/TCP     71s     app.kubernetes.io/app=ledger,app.kubernetes.io/instance=my-release-scalardl,app.kubernetes.io/name=scalardl
      
       NAME                                            ENDPOINTS                                                             AGE
       endpoints/kubernetes                            172.20.2.134:443,172.20.4.152:443                                     3h
       endpoints/my-release-scalardl-envoy             172.20.2.39:50052,172.20.4.7:50052,172.20.4.96:50052 + 3 more...      71s
       endpoints/my-release-scalardl-envoy-metrics     172.20.2.39:9001,172.20.4.7:9001,172.20.4.96:9001                     71s
       endpoints/my-release-scalardl-ledger-headless   172.20.2.26:50051,172.20.4.166:50051,172.20.4.231:50051 + 6 more...   71s
       ```

### EKS クラスタの監視機能の確認

* EKS クラスタのメトリクスが CloudWatch の `Container Insights` で参照可能であることを確認します。
* コンテナのログが CloudWatch の `Log` で参照可能であることを確認します。

### データベース監視機能の確認

* CloudWatch のメトリクスで DyanmoDB のメトリクスが参照可能であることを確認します。

## リソースの削除

作成したリソースを削除する必要がある場合は、以下の順序でリソースを削除してください。

* Scalar DL
* ノードグループ
* EKS クラスタ
* データベース
* 踏み台サーバー
* NAT ゲートウェイ
* VPC

### Scalar DL のアンインストール

Scalar DL Ledger をアンインストールする場合は、以下の helm コマンドを使用します。

   ```console
   # Uninstall loaded schema with a release name 'load-schema'
   helm uninstall load-schema
   
   # Uninstall Scalar DL with a release name 'my-release-scalardl'
   helm uninstall my-release-scalardl
   ```

Scalar DL Auditor をアンインストールする場合は、以下の helm コマンドを使用します。

   ```console
   # Uninstall loaded schema with a release name 'load-audit-schema'
   helm uninstall load-audit-schema
   
   # Uninstall Scalar DL Auditor with a release name 'my-release-scalar-audit'
   helm uninstall my-release-scalardl-audit
   ```

### その他のリソースの削除

その他のリソースは、AWS のウェブコンソールやコマンドラインインターフェースを利用して削除できます。  
各リソースの削除方法については、EKS のドキュメントを参照してください。

* [AWS 公式ドキュメント "Deleting an Amazon EKS cluster"](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html)
* [AWS 公式ドキュメント "Deleting a managed node group"](https://docs.aws.amazon.com/eks/latest/userguide/delete-managed-node-group.html)
