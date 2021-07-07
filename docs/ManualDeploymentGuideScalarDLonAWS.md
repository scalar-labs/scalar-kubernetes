# Deploy Scalar DL on AWS

Scalar DL is a database-agnostic distributed ledger middleware containerized with Docker. 
It can be deployed on various platforms and is recommended to be deployed on managed services for production to achieve high availability and scalability, and maintainability. 
This guide shows you how to manually deploy Scalar DL on a managed database service and a managed Kubernetes service in Amazon Web Services (AWS) as a starting point for deploying Scalar DL for production. 

## What we create

![image](images/network_diagram_eks.png)

In this guide, we will create the following components.

* A VPC with NAT gateway
* An EKS cluster with two Kubernetes node groups
* A managed database service 
    * DynamoDB    
* A Bastion instance with a public IP
* Amazon CloudWatch

## Step 1. Configure your network

Configure a secure network with your organizational or application standards. Scalar DL handles highly sensitive data of your application, so you should create a highly secure network for production. 
This section shows how to configure a secure network for Scalar DL deployments.

### Requirements
 
* You must create VPC with NAT gateways on private networks. NAT gateway is necessary to enable internet access for Kubernetes node group subnets.
* You must create at least 2 subnets for the EKS cluster in different availability zones. This is mandatory to create an EKS cluster.
* You must create subnets with the prefix at least `/24` for the Kubernetes cluster to work without issues even after scaling. 

### Recommendations

* You should create private subnets for the Kubernetes cluster for production.
* You should create a bastion server to manage the Kubernetes cluster.
* You should create 3 subnets in 3 availability zones for the Kubernetes cluster for higher availability. 
* You should create public subnets for the Kubernetes cluster if you want to place envoy LoadBalancer in the public subnet for testing purposes.

### Steps

* Create an Amazon VPC on the basis of [AWS official guide](https://docs.aws.amazon.com/batch/latest/userguide/create-public-private-vpc.html) with the above requirements and recommendations.

## Step 2. Set up a database 

In this section, you will set up a database for Scalar DL.

### Requirements

* You must have a database that Scalar DL supports.

### Steps

* Follow [Set up a database guide](./ScalarDLSupportedDatabase.md) to set up a database for Scalar DL.

## Step 3. Configure EKS

This section shows how to create an EKS cluster and 2 managed node groups(one for ledger and envoy and one for logs and metrics collection) for Scalar DL and monitor agent deployment.

### Prerequisites

Install the following tools on your bastion for controlling the EKS cluster:
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html): In this guide, AWS CLI is used to create a kubeconfig file to access the EKS cluster.
* [kubectl](https://kubernetes.io/docs/tasks/tools/): Kubernetes command-line tool to manage EKS cluster. Kubectl 1.19 or higher is required.

### Requirements

* You must create a Kubernetes cluster with version 1.19 or higher for Scalar DL deployment.
* You must create a node group with the label, key as `agentpool` and value as `scalardlpool` for Scalar DL deployment.
* You must add a rule in the EKS security group to **enable HTTPS access (Port 443)** to the private EKS cluster from the bastion server.

### Recommendations

* You should create nodes with node size `m5.xlarge` for the Scalar DL node group and `m5.large` for the default node group.
* You should create 3 nodes in each node group for high availability in the production.
* You should configure Cluster autoscaler on the basis of [AWS official guide](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html) to scale the number of nodes in your cluster.

### Steps

* Create an Amazon EKS cluster on the basis of [AWS official guide](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html). 
* Create a managed node group on the basis of [AWS official guide](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) with the above requirements and recommendations.
* Configure kubectl to connect to your Kubernetes cluster using the `aws eks update-kubeconfig` command. 
    
   ```console
    $ aws eks --region <region-code> update-kubeconfig --name <cluster_name>
   ```

## Step 4. Install Scalar DL

After creating a Kubernetes cluster next step is to deploy Scalar DL into the EKS cluster.
This section shows how to install Scalar DL to the EKS cluster with [Helm charts](https://github.com/scalar-labs/helm-charts).

### Prerequisites

Install the Helm on your bastion to deploy helm-charts:

* [Helm](https://helm.sh/docs/intro/install/): helm command-line tool to manage releases in the EKS cluster. In this tutorial, it is used to deploy Scalar DL and Schema loading helm charts to the EKS cluster. Helm version 3.5 or latest is required.

### Requirements

* You must have the authority to pull `scalar-ledger` and `scalardl-schema-loader` container images.
* You must configure the database properties in the helm chart custom values file.
* You must confirm that the replica count of the ledger and envoy pods in the `scalardl-custom-values.yaml` file is equal to the number of nodes in the Scalar DL node group.

### Steps

The following steps show how to install Scalar DL on EKS:

1. Download the following Scalar DL configuration files from the [scalar-kubernetes repository](https://github.com/scalar-labs/scalar-kubernetes/tree/master/conf). 
Note that they are going to be versioned in the future, so you might want to change the branch to use a proper version.
    * scalardl-custom-values.yaml
    * schema-loading-custom-values.yaml
 
2. Update the database configuration in scalarLedgerConfiguration and schemaLoading sections as specified in [Set up a database guide](./ScalarDLSupportedDatabase.md#Configure-Scalar-DL).
3. Create the docker-registry secrets for pulling the Scalar DL images from the GitHub registry
    
   ```console
    $ kubectl create secret docker-registry reg-docker-secrets --docker-server=ghcr.io --docker-username=<github-username> --docker-password=<github-personal-access-token>
   ```

4. Run the Helm commands on the bastion machine to install Scalar DL on EKS
    
   ```console
    # Add Helm charts 
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
* You should confirm the load-schema deployment has been completed with `kubectl get pods -o wide` before installing Scalar DL.
* Follow the [Maintain Scalar DL Pods ](./MaintainPods.md) for maintaining Scalar DL pods with Helm.

## Step 5. Monitor the Cluster

It is critical to actively monitor the overall health and performance of a cluster running in production. 
You can use Container Insights to collect performance metrics and Fluent Bit to collect logs of the EKS cluster.
This section shows how to configure monitoring and logging for your EKS cluster.

### Recommendations

* You should enable monitoring for EKS in the production.
* You should configure cloudwatch agent in the EKS cluster for collecting metrics from pods. 
* You should configure Fluent Bit in the EKS cluster for collecting logs from pods.
    * You should create a CloudWatch Logs policy with `CreateLogGroup`, `CreateLogStream`, and `PutLogEvents` permissions and attach the policy to the Node instance role.
        
### Steps

* Setup CloudWatch agent and Fluent Bit in the EKS cluster based on [AWS official guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).

## Step 6. Checklist for confirming Scalar DL deployments

After the Scalar DL deployment, you need to confirm that deployment has been completed successfully. This section will help you to confirm the deployment.

### Confirm Scalar DL deployment

* Make sure the schema is properly created in the underlying database service.

* You can check if the pods and the services are properly deployed by running the `kubectl get pods,services -o wide` command on the bastion.
    * You should confirm the status of all ledger and envoy pods are `Running`.
    * You should confirm the `EXTERNAL-IP` of Scalar DL envoy service is created.      

   ```console    
    $ kubectl get pods,services -o wide
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

### Confirm EKS cluster monitoring

* Confirm the EKS cluster metrics are available in CloudWatch `Container Insights`.
* Confirm the Container logs are available in CloudWatch `Log`.

### Confirm Database monitoring

* Confirm the database metrics are available in CloudWatch metrics.

## Clean up the resources

When you need to remove the resources that you have created, remove the resources in the following order.

* Scalar DL 
* Managed node group
* EKS cluster
* DynamoDB
* Bastion server
* NAT gateway
* VPC

### Uninstall Scalar DL 

You can uninstall Scalar DL installation with the following Helm commands:

   ```console
    # Uninstall loaded schema with a release name 'load-schema'
    $ helm delete load-schema

    # Uninstall Scalar DL with a release name 'my-release-scalardl'
    $ helm delete my-release-scalardl
   ```

### Clean up the other resources

You can remove the other resources via the web console or the command-line interface.

For more detail about the command-line interface, please take a look at the [official document](https://docs.aws.amazon.com/cli/index.html?nc2=h_ql_doc_cli).    