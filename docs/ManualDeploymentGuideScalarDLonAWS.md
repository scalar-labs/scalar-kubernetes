# Deploy Scalar DL on AWS

Scalar DL is a database-agnostic distributed ledger middleware containerized with Docker. 
It can be deployed on various platforms and is recommended to be deployed on managed services for production to achieve high availability and scalability, and maintainability. 
This guide shows you how to manually deploy Scalar DL on a managed database service and a managed Kubernetes service in Amazon Web Services (AWS) as a starting point of deploying Scalar DL for production.

## What we create

![image](images/network_diagram_eks.png)

In this guide, we will create the following components.

* A VPC with NAT gateway
* An EKS cluster with two Kubernetes node groups
* A managed database service (you can choose one of them)
    * DynamoDB
    * RDS (MySQL/PostgreSQL)
* 1 Bastion instance with a public IP
* Amazon CloudWatch

## Step 1. Configure your network

Configure a secure network with your organizational or application standards. 
Scalar DL handles highly sensitive data of your application, so you should create a highly secure network for production. This section will help you to configure a secure network for Scalar DL deployments.

### Requirements
 
* You must have a VPC, with NAT gateways on private subnets. NAT gateway is necessary to enable internet access for Kubernetes node group subnets.
* You must have at least 2 subnets in different AZs for the Kubernetes cluster. This is mandatory to create an EKS cluster.
* You must have at least one private subnet for the managed database(RDS) other than Dynamo DB.
* You must create subnets with the prefix at least _/24_ for the Kubernetes cluster to work without issues even after scaling. 

### Recommendations

* Kubernetes should be private in production and should provide secure access with SSH or VPN. You can use a bastion server as a host machine for secure access to the private network.
* Subnets should be in multiple availability zones to achieve fault tolerance for the production use..
* Kubernetes cluster should have public subnets to enable the envoy public endpoint(Scalar DL can be accessed from the internet). The Kubernetes cluster in public is not recommended for production.

_Tip_ 

_If you plan to create three or more nodes in a Kubernetes node group for high availability, create at least 3 subnets in different AZs for the Kubernetes cluster._

[Create an Amazon VPC](https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html) with the above requirements and recommendations along with your organizational or application standards.

## Step 2. Set up a database 

In this section, you will set up a database for Scalar DL.

### Requirements

* You must have a database that Scalar DL supports.

Follow the [Set up a Scalar DL supported database](ScalarDLSupportedDatabase.md) document to Set up a Database for Scalar DL.

## Step 3. Configure EKS

This section shows how to configure a Kubernetes service for Scalar DL deployment.

### Prerequisites

Install the following tools on your host machine:
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html): In this guide, AWS CLI is used to create a kubeconfig file to access the EKS cluster.
* [kubectl](https://kubernetes.io/docs/tasks/tools/): Kubernetes command-line tool to manage EKS cluster. Kubectl 1.19 or higher is required.

### Requirements

* You must have an EKS cluster with Kubernetes version 1.19 or above in order to use our most up-to-date configuration files.
* Kubernetes node group must be labeled with key as `agentpool` and value as `scalardlpool` for [ledger](https://github.com/scalar-labs/scalardl) and [envoy](https://www.envoyproxy.io/) deployment.
* If you are creating a Kubernetes cluster on a private subnet, you must add a new rule in the Kubernetes Security Group to enable HTTPS access from the bastion server to the Kubernetes cluster.

### Recommendations

* Kubernetes node size should be `m5.xlarge` for deploying `ledger` and `envoy` pods, because each node requires 4 vCPUs and 16 GiB of memory for deploying ledger and envoy pods.
* Node groups should have at least 3 nodes for high availability in production.
* [Cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html) should be configured to adjust the number of nodes in your cluster when pods fail or are rescheduled onto other nodes.

### Create a Kubernetes cluster	

Scalar DL requires a single EKS cluster for deploying ledger, envoy and monitor services. This section section shows how to create an EKS cluster. 

[Create an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) with the above requirements.

* Configure kubectl to connect to your Kubernetes cluster using the `aws eks update-kubeconfig` command. 
The following command downloads credentials and configures the Kubernetes CLI to use them from the host machine.

    ```console
    $ aws eks --region <region-code> update-kubeconfig --name <cluster_name>
    ```
  
_Tip_

_If you are creating a Kubernetes cluster on a private subnet, you must add a new rule in the Kubernetes Security Group to enable HTTPS access to the public subnet from the Kubernetes cluster._

### Create managed node groups

This section will guide you to create two managed node groups for Scalar DL deployment. 
Create a managed node group for ledger and envoy deployment, and create another managed node group for deploying logs and metrics collection agents.

[Create a managed node group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) with the above requirements and recommendations.

## Step 4. Install Scalar DL

After creating Kubernetes cluster next step is to deploy Scalar DL into the EKS cluster.
This section shows how to install Scalar DL to the EKS cluster with [Helm charts](https://github.com/scalar-labs/helm-charts).

### Prerequisites

Install the following tools on your host machine:

* [helm](https://helm.sh/docs/intro/install/): helm command-line tool to manage releases in the EKS cluster. In this tutorial, it is used to deploy Scalar DL and Schema loading helm charts to the EKS cluster. Helm version 3.5 or latest is required.

### Requirements

* You must have the authority to pull `scalar-ledger` and `scalardl-schema-loader` container images.
* You must configure the database properties in the helm chart custom values file.
* You must confirm that replica count of the ledger and envoy pods in the `scalardl-custom-values.yaml` file is equal to the number of nodes with `agentpool=scalardl` label.

### Deploy Scalar DL

Following steps show how to install Scalar DL on EKS:

1. Download the following Scalar DL configuration files and update the database configuration in `scalarLedgerConfiguration` and `schemaLoading` sections
    * [scalardl-custom-values.yaml](https://raw.githubusercontent.com/scalar-labs/scalar-kubernetes/master/conf/scalardl-custom-values.yaml)
    * [schema-loading-custom-values.yaml](https://raw.githubusercontent.com/scalar-labs/scalar-kubernetes/master/conf/schema-loading-custom-values.yaml)
2. Create the docker-registry secret for pulling the Scalar DL images from the GitHub registry
    
   ```console
    $ kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
   ```

3. Run the helm commands on the host machine to install Scalar DL on EKS
    
   ```console
    # Add helm charts 
    $ helm repo add scalar-labs https://scalar-labs.github.io/helm-charts
    
    # List the Scalar charts.
    $ helm search repo scalar-labs
    
    # Load Schema for Scalar DL install with a release name `load-schema`
    $ helm upgrade --install load-schema scalar-labs/schema-loading --namespace default -f schema-loading-custom-values.yaml
    
    # Install Scalar DL with a release name `my-release-scalardl`
    $ helm upgrade --install my-release-scalardl scalar-labs/scalardl --namespace default -f scalardl-custom-values.yaml
    ```

Note:

* The same commands can be used to upgrade the pods.
* Release name `my-release-scalardl` can be changed as per your convenience.
* `helm ls -a` command can be used to list currently installed releases.
* You should confirm the load-schema deployment has been completed with `kubectl get po -o wide` before installing Scalar DL.
* Follow the [Maintain the cluster](./Maintaincluster.md) section for more customization.

## Step 5. Monitor the Cluster

It is critical to actively monitor the overall health and performance of a cluster running in production. 
You can use Container Insights to collect performance metrics and Fluent Bit to collect logs of the EKS cluster.
This section show how to configure monitoring and logging for your EKS cluster.

### Recommendations

* Monitoring should be enabled for EKS in production.
* CloudWatch agent should be configured in the EKS cluster for collecting metrics from pods.
* Fluent Bit should be configured in the EKS cluster for collecting logs from pods.
    * Node instance role must have `CreateLogGroup`, `CreateLogStream` and `PutLogEvents` permission for Fluent bit.

### Set up Container Insights and Fluent Bit

CloudWatch Container Insights helps you to collect, aggregate, and summarize metrics and logs from your containerized applications and Fluent Bit allows you to collect logs from containerized applications and route logs to Amazon CloudWatch. 
Set up CloudWatch agent and Fluent Bit in the node group created for log and metrics collection.

[Setup CloudWatch agent and Fluent Bit in the EKS cluster](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).

## Step 6. Checklist for confirming Scalar DL deployments

After the Scalar DL deployment, you need to confirm that deployment has been completed successfully. This section shows how to confirm the deployment.

### Confirm Scalar DL deployment

You can check if the pods and the services are properly deployed by running the `kubectl get po,svc,endpoints -o wide` command on the host machine.

   ```console    
    $ kubectl get po,svc,endpoints -o wide
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
* Make sure the schema is properly created in the underlying database service.

### Confirm EKS cluster monitoring

* Confirm the EKS cluster metrics are available in CloudWatch `Container Insights`.
* Confirm the Container logs are available in CloudWatch `Log`.

### Confirm Database monitoring

* Confirm the database metrics are available in CloudWatch metrics.

## Uninstall Scalar DL

You can uninstall Scalar DL installation with the following helm commands:

   ```console
    # Uninstall loaded schema with a release name 'load-schema'
    $ helm delete load-schema

    # Uninstall Scalar DL with a release name 'my-release-scalardl'
    $ helm delete my-release-scalardl
   ```
