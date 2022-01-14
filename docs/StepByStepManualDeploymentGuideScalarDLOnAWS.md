# Example steps to Deploy Scalar DL on AWS

This guide assumes that you create the environment based on the [manual deployment guide for AWS](./ManualDeploymentGuideScalarDLOnAWS.md).
This document contains example steps for creating a Scalar DL environment in the AWS cloud.

Following are the resources to be created using this document.

* An AWS VPC
* Private DNS Zone for internal host lookup
* Bastion Instance with a public IP
* Database resource (any one of the following)
  * DynamoDB
  * MySQL server
  * PostgreSQL server
* Kubernetes Cluster

## Create Virtual Private Network

Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

The following steps help you to create a virtual private cloud.

* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, Select **Your VPCs**
* Select **Create VPC**
* Enter **Name tag**
* Enter **IPv4 CIDR block** as _10.42.0.0/16_
* Select **Create VPC**

### Create Subnets
* In the navigation pane, select **Subnets**
* Select **Create subnet**
* Select your **VPC ID** from the dropdown
* On the **Subnet settings** section, configure subnets
  * Enter **Subnet name**
  * Select an **Availability Zone**
  * Enter **IPv4 CIDR block**
  * Select **Add new subnet** and repeat the above 3 steps if you need to add more subnets

  _(Use `Subnet name`, `Availability Zone` and `Address range` details from the below table.)_

| Subnet Name | Availability Zone | Address range | 
 |:------------|:------------------|:--------------|
| public-01     |  az-1  | 10.42.0.0/26|
| public-02    |  az-2   | 10.42.0.64/26|
| public-03    |  az-3   |  10.42.0.128/26 |
| kubernetes-01|  az-1   | 10.42.41.0/24|
| kubernetes-02|  az-2   | 10.42.42.0/24|
| kubernetes-03|  az-3   | 10.42.43.0/24|
| private-01|  az-1   | 10.42.1.0/26|
| private-02|  az-2   | 10.42.1.64/26|
| private-03|  az-3   |  10.42.1.128/26 |
| Rds-01   |  az-1    |  10.42.4.0/26  |
| Rds-02   | az-2     |  10.42.4.64/26  |
| Rds-03   | az-3     |  10.42.4.128/26 |

```
Note: 
* Rds-01, Rds-02, Rds-03 is only needed if you use MySQL or PostgreSQL RDS instance as underlying database/storage for Scalar DL.
* Create only one public subnet, a private subnet, Kubernetes subnet, and Rds subnet If you use a single Availability Zone.  
```

* After Adding the Subnets, select **Create Subnet**

### Create Internet Gateway

Internet Gateway is a highly available VPC component that allows communication between your VPC and the internet.

The following steps help you to create an Internet Gateway.

* In the navigation pane, choose **Internet Gateways**
* Select **Create internet gateway**
* Enter **Name tag**
* Select **Create internet gateway**
* Select **Actions**
* Select **Attach to VPC**
* On the **Attach to VPC** page, configure the following options
  * Select your _VPC_ from the **Available VPCs** dropdown
  * Select **Attach internet gateway**

### Create NAT Gateway

You can use a network address translation (NAT) gateway to enable instances in a private subnet to connect to the internet or other AWS services, but prevent the internet from initiating a connection with those instances.

Repeat the following steps to create NAT gateways for all public subnets (eg: public-01, public-02 and public-03),
* In the navigation pane, choose **NAT Gateways**
* Select **Create NAT gateway**
* On the **Create NAT gateway** page, configure the following options
  * Enter **Name**
  * Select public subnet as **Subnet**
  * Select **Allocate Elastic IP**
  * Select **Create NAT gateway**
    It will take some for the NAT gateway state to become available.

### Create Public Route table

A route table contains a set of rules, called routes, used to determine where network traffic from your subnet or gateway is directed.

Create Route table for Public subnets to access the internet through internet gateway using the following steps
* In the navigation pane, choose **Route Tables**
* Select **Create route table**
  * Enter **Name tag**
  * Select your **VPC** from the dropdown
  * Select **Create route table**
  * Select **Close** after seeing the success message
* On the **Route tables** page, configure routes to direct Internet access to the VPC to public subnets
  * Select previously created Route table
  * On the details pane, select the **Routes** tab
  * Select **Edit routes**
  * On the **Edit routes** page, configure the following options
    * Select **Add route**
    * Enter _0.0.0.0/0_ on **Destination**
    * Select _Internet Gateway_ on **Target** and select your internet gateway
    * Select **Save changes**
    * Select **Close**
  * On the details pane, select the **Subnet association** tab
    * Select **Edit subnet association**
    * Select all your previously created public subnets
    * Select **Save associations**

### Create Private Route Tables
Create route table for NAT gateways, repeat the following steps for all NAT gateways
* In the navigation pane, choose **Route Tables**
* Select **Create route table**
  * Enter **Name tag**
  * Select your **VPC** from the dropdown
  * Select **Create route table**
  * Select **Close**
* On the **Route tables** page, configure routes and associate subnets for private Route tables using the following steps
  * Select previously created Route table
  * On the details pane, select the **Routes** tab
  * Select **Edit routes**
  * On the **Edit routes** page, configure the following options
    * Select **Add route**
    * Enter _0.0.0.0/0_ on **Destination**
    * Select _NAT Gateway_ on **Target** and select your NAT gateway
    * Select **Save changes**
    * Select **Close**
  * On the details pane, select the **Subnet association** tab
    * Select **Edit subnet association**
    * Select the **Subnet Id** (follow the below table and associate subnets for each NAT gateway respectively)
    * Select **Save associations**

  | NAT Gateway | Subnets |  
    |:------------|:-------|
  | NAT-01      | kubernetes-01, private-01|
  | NAT-02     | kubernetes-02, private-02|
  | NAT-03      | kubernetes-03,private-03 |  

## Create Private DNS Zone

A Private DNS zone is used for the internal name resolution of the servers. The private DNS name can be used instead of the private IP address of the server.

* Open the Amazon [Route53](https://console.aws.amazon.com/route53/) service
* In the navigation pane, choose **Hosted zones**
* Click **Create hosted zone**
* On the **Create hosted zone** page, configure the following options
  * Enter **Domain name** as _internal.scalar-labs.com_
  * Enter **Description**
  * Select _Private hosted zone_ in **Type**
  * Select **Region** from the dropdown
  * Select your **VPC ID**
  * Select **Create hosted zone**

## Create a bastion server

A Bastion host is a server whose purpose is to provide access to a private network from an external network, such as the Internet. We can access Scalar DL resources through this server.

* Open the Amazon [EC2](https://console.aws.amazon.com/ec2/) service
* In the navigation pane, Choose **Instances**
* Select **Launch Instances**
* On the **Choose AMI** page, select AMI _Amazon Linux 2 AMI (HVM), SSD Volume Type_
  * Select **64-bit (x86)** (It will be the default selection).
* On the **Choose Instance Type** page, select _t3.micro_
* On the **Configure Instance** page, configure the following options
  * Select **Number of instances** as 1
  * Select your VPC in **Network**
  * Select **Subnet** public
  * Select **Auto-assign Public IP** as _Enable_ from the dropdown
* On the **Add Storage** page, configure the following options
  * Enter **Size(GB)** as _16_
* Select **Review and Launch**, confirm the values once again and select **Launch**
* On the Pop up window, configure the following options
  * Select **Create a new key pair** from the dropdown
  * Enter **Key pair name**
  * Click **Download Key Pair**
  * Click **Launch Instances**
* On the **Launch Status** page, click **View instances**
* Select newly created instance
* Click on the **Name** column
* Enter a name for the server
* Select **Save**

### Create DNS Record for Bastion Server

* Open the Amazon [Route53](https://console.aws.amazon.com/route53/) service
* In the navigation pane, choose **Hosted zones**
* Click on _internal.scalar-labs.com_ (previously created private DNS)
* On the **Hosted zone details** page, create a new record
* Select **Create record**
  * Enter _bastion-1_ as **Record name**
  * Select **Record type** as _A - Routes traffic to an IPv4 address and some AWS resources_ from the dropdown
  * Enter **Value** as private IP of previously created bastion server.
  * Use default values for **TTL(seconds)** and **Routing policy**
  * Select **Create records**
```
Note: If more than one bastion server is created, enter Value and Record name accordingly 
```

# Create a backend Database

We can use any of the following databases as an underlying database/storage for Scalar DL.

## Create DynamoDB

For DynamoDB Scalar Schema can be created directly during Scalar DL deployment.

## Create MySQL server

To use MySQL as the database for the Scalar DL, create an RDS MySQL server using the following steps.

* Open the [Amazon RDS](https://console.aws.amazon.com/rds/) service
* First, create a DB subnet group for the RDS instance, follow the steps for creating a DB subnet group
* In the navigation pane, choose **Subnet groups**
  * Select **Create DB Subnet Group**
  * Enter a **Name** for the Subnet group
  * Enter a **Description**
  * Select your **VPC** from the dropdown
  * Choose the **Availability Zones**
  * Choose the Rds subnets
  * Select **Create**
* In the navigation pane, choose **Databases**.
* Select **Create database**
* On the **Choose a database creation method** section, select _Standard create_
* On the **Engine options**, choose the **Engine type** as _MySQL_
* For the **Version** option, choose the MySQL **Version** from the dropdown
* Select _Production_ in **Templates**
* On the **Settings** section, configure the following options
  * Enter **DB instance identifier** (enter name for the database must be lowercase)
  * Enter **Master username** as _root_
  * Enter **Master password**
  * Enter the same password again to **Confirm password**
* Select **DB instance class**
* Select **Storage type** as  _General Purpose(SSD)_ from the dropdown
* Enter **Allocated storage**
* Click Tick on **Enable storage autoscaling**
* Enter **Maximum storage threshold** as _1000_
* On the **Availability & durability**, select _Create a standby instance (recommended for production usage)_
* On the **Connectivity** section, configure the following options
  * Select your **Virtual private cloud (VPC)** from the dropdown
  * Select previously created **Subnet group** from the dropdown
  * Select **Public Access** as _No_
  * Select _Create new_ for VPC security group
  * Enter **New VPC security group name**
* On the **Database authentication** section, select _Password authentication_
* Select **Create database**

## Create PostgreSQL server

To use PostgreSQL as the database for the Scalar DL, create an RDS PostgreSQL server using the following steps.

* Open the [Amazon RDS](https://console.aws.amazon.com/rds/) service
* First, create a **DB subnet group** for the RDS instance, follow the steps for creating a DB subnet group
* In the navigation pane, choose **Subnet groups**
  * Select **Create DB Subnet Group**
  * Enter **Name** for the Subnet group
  * Enter a **Description**
  * Select your **VPC** from the dropdown
  * Choose **Availability Zones**
  * Choose the Rds subnets
  * Select **Create**
* In the navigation pane, choose **Databases**.
* Select **Create database**.
* On the **Choose a database creation method**, select _Standard create_
* On the **Engine options**, choose the Engine type _PostgreSQL_
* For **Version**, choose the PostgreSQL **Version** from the dropdown
* Select _Production_ in **Templates**
* On the **Settings** section, configure the following options
  * Enter **DB instance identifier** (enter name for the database must be lowercase)
  * Enter **Master username** as _postgres_
  * Enter **Master password**
  * Enter the same password again to **Confirm password**
* Select **DB instance class**
* Select **Storage type** as _General Purpose(SSD)_ from the dropdown
* Enter **Allocated storage**
* Click Tick on _Enable storage autoscaling_
* Enter **Maximum storage threshold** as 1000
* On the **Availability & durability**, select _Create a standby instance (recommended for production usage)_
* On the **Connectivity** section, configure the following options
  * Select your **Virtual Private Cloud** from the dropdown
  * Select previously created **Subnet group** from the dropdown
  * Select **Public Access** as _No_
  * Select _Create new_ for **VPC security group**
  * Enter **New VPC security group name**
* On the **Database authentication** section, select _Password authentication_
* Select **Create database**

## Create a Kubernetes cluster for Scalar DL

Kubernetes is an open-source container-orchestration system for automating computer application deployment, scaling, and management. Scalar-ledger and envoy services can be deployed as pods to a Kubernetes cluster. In AWS, we use Elastic Kubernetes Service (EKS) for it.

The following steps help you to create a Kubernetes cluster.

* Open the Amazon [EKS](https://console.aws.amazon.com/eks/home#/clusters) service
* Select **Create Cluster**
* On the **Configure cluster** page, configure the following options
  * Enter a **Name** for the cluster
  * Select **Kubernetes version** as _1.19_  or higher from the dropdown
  * Select `eksClusterRole` for **Cluster Service Role**, (if eksClusterRole is not created please follow [Creating the Amazon EKS cluster role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html]))
  * Select **Next**
* On the **Specify networking** page, configure the following options
  * Select your **VPC**
  * Select **Subnets** as previously created Kubernetes subnets, private subnets and public subnets from the dropdown
  * Select _bastion_ **Security groups** from the dropdown
  * Select _Public and Private_ as **Cluster endpoint access**
  * Select **Amazon VPC CNI** _v1.7.5-eksbuild.1_ or higher from the dropdown
  * Select **Next**
* On the **Configure logging page**, enable the following logs
  * _API server_
  * _Controller manager_
* Select **Next**
* On the **Review and Create** page, confirm the settings and select **Create**

### Create Node Group

The following steps help you to create Node Group `default`.

* On your **Kubernetes cluster** page, select **Configuration** tab
* Select **Compute** tab
* Select **Add Node Group**
* On the **Configure Node Group** page, configure the following options
  * Enter **Name** as _default_
  * Select **Node IAM Role** as `eksNodeRole` (if eksNodeRole is not found, please follow [Creating the Amazon EKS node IAM role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html))
  * Select **Next**
* On the **Set compute and scaling configuration** page, configure the following options
  * Select **AMI type** as _Amazon Linux 2 (AL2_x86_64)_ from the dropdown
  * Select **Capacity type** as _On-Demand_ from the dropdown
  * Select **instance types** as _m5.large_ from the dropdown. Remove the default selection if it is a different size.
  * Enter **Disk size** as _64_
  * Select **Minimum size**, **Desired size** as 3 and **Maximum size** as 6 in **Node Group scaling configuration** section
  * Select **Next**
* On the **Specify networking** page, configure the following options
  * Select all your private subnets as **Subnets**
  * Enable **Configure SSH access to nodes**
  * Select **SSH key pair** (select key pair which was created for bastion)
  * Select _All_ for **Allow remote access from**
  * Select **Next**
* On the **Review and Create** page, confirm the settings and select **Create**

The following steps help you to create Node Group `scalardlpool` for Scalar DL deployment.

* On your **Kubernetes cluster** page, select **Configuration** tab
* Select **Compute** tab
* Select **Add Node Group**
* On the **Configure Node Group** page, configure the following options
  * Enter **Name** as _scalardlpool_
  * Select **Node IAM Role** as `eksNodeRole` (if eksNodeRole is not found, please follow [Creating the Amazon EKS node IAM role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html))
  * Select **Add label** in **Kubernetes labels** section and configure the following label
    * Key: agentpool
    * Value: scalardlpool
  * Select **Next**
* On the **Set compute and scaling configuration** page, configure the following options
  * Select **AMI type** as _Amazon Linux 2 (AL2_x86_64)_ from the dropdown
  * Select **Capacity type** as _On-Demand_ from the dropdown
  * Select **instance types** as _m5.xlarge_ from the dropdown. Remove the default selection if it is a different size.
  * Enter **Disk size** as _64_
  * Select **Minimum size**, **Desired size** as 3 and **Maximum size** as 6 in **Node Group scaling configuration** section
  * Select **Next**
* On the **Specify networking** page, configure the following options
  * Select all your Kubernetes subnets as **Subnets**
  * Enable **Configure SSH access to nodes**
  * Select **SSH key pair**(select key pair which was created for bastion)
  * Select _All_ for **Allow remote access from**
  * Select **Next**
* On the **Review and create** page, confirm the settings and select **Create**

#### Create an IAM role for bastion to access the Kubernetes cluster

Create an IAM role for the bastion to access the EKS cluster from the bastion using the following steps

* Open the Amazon [IAM](https://console.aws.amazon.com/iam/) service
* In the navigation pane, select **Roles**
* Select **Create role**
* Select **AWS service**
* Select **EC2**
* Select **Next:Permissions**
* Select **Next:Tags**
* Select **Next:Review**
* Enter **Role name**
* Enter **Role description**
* Select **Create role**
* Click on the newly created role
* On the **Permissions** tab, Click on **Add inline policy**
  * Select **JSON** tab and paste the following JSON

```
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"eks:*"
		],
		"Resource": "<ARN of kubernetes cluster>"
	}]
}
```
```
Note: Replace the arn of your Kubernetes cluster in place of  <ARN of kubernetes cluster> (it can be obtained from **Cluster ARN** from your Kubernetes cluster Configuration page)
```

* Select **Review policy**
* On the **Review policy** page, enter a **Name** for the Policy
* Select **Create policy**

Attach the above policy to the bastion server using the following steps
* Open the Amazon [EC2](https://console.aws.amazon.com/ec2/) service
* Select your bastion server
* Select **Actions** on top
* Select **Security** and choose **Modify IAM role**
* On the **Modify IAM role** page, select the previously created role
* Click **Save**


## Setup Bastion
* SSH to Bastion server
Follow the _Prerequisites_ of _Configure EKS_ in the [manual deployment guide for AWS](./ManualDeploymentGuideScalarDLOnAWS.md#prerequisites)

* Create file `aws-auth-cm.yaml` with the following content

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <ARN of node instance role>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: <ARN of Bastion Instance Role>
      username: <Bastion Instance profile name>
      groups:
        - system:masters
```

* Replace the following in the file
1. ARN of node instance role: ARN of EKS cluster node instance role
2. ARN of Bastion Instance Role: Role created for bastion server
3. Bastion Instance profile name: instance profile name of bastion server
* Create kubeconfig in bastion to access the Kubernetes cluster with the following command

```
$ aws eks --region <your region> update-kubeconfig --name <eks cluster name>
```

* Apply the configuration. This command may take a few minutes to finish.

```
kubectl apply -f aws-auth-cm.yaml
```

## Install Scalar DL

Install Scalar DL to the EKS cluster based on [manual deployment guide for AWS](./ManualDeploymentGuideScalarDLOnAWS.md#step-4-install-scalar-dl)

### Confirm Scalar DL deployment

Confirm the Scalar DL deployment based on [manual deployment guide for AWS](./ManualDeploymentGuideScalarDLOnAWS.md#confirm-scalar-dl-deployment)

### Deploy Scalar DL with Helm

Follow [Deploy Scalar DL with Helm](https://github.com/scalar-labs/scalar-kubernetes/blob/master/docs/DeployScalarDLHelm.md) to load the scalar schema and deploy Scalar DL to the Kubernetes cluster.

## How to access Kubernetes Monitor

The following steps help you to create an inline policy in `eksNodeRole` for pod logging.
* Open the Amazon [IAM](https://console.aws.amazon.com/iam/) service
* In the navigation pane select **Roles**
* Select `eksNodeRole`
* On the **Permissions** tab, Click on **Add inline policy**
  * Select **JSON** tab and paste the following JSON
```
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogStream",
			"logs:DescribeLogGroups",
			"logs:CreateLogGroup",
			"logs:PutLogEvents"
		],
		"Resource": "*"
	}]
}}
```
* Select **Review policy**
* On the **Review policy** page, enter a **Name** for the Policy
* Select **Create policy**

Setup container insights to enable pod's performance matrix and logging, following steps help you to set up container insights.

* SSH to bastion server
* Follow [setup cloudwatch agent to collect cluster metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html)
* Follow [setup fluentbit to send logs to Cloudwatch logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html)

The following steps help you to access the Kubernetes monitor.

* Open the Amazon [CloudWatch](https://console.aws.amazon.com/cloudwatch/home#logs:prefix=/aws/eks) service
* In the navigation pane, select **Resources**

The following steps help you to access the Kubernetes logging.

* Open the Amazon [CloudWatch](https://console.aws.amazon.com/cloudwatch/home#logs:prefix=/aws/eks) service
* Filter log groups with `/aws/containerinsights/<cluster-name>/`
* Choose the log stream to view

## Clean up the resources

Remove the Scalar DL installation based on [manual deployment guide for AWS](./ManualDeploymentGuideScalarDLOnAWS.md#uninstall-scalar-dl)

Clean up other resources using the following steps

To remove the **EKS cluster**, you can use the following steps
* Open the Amazon [EKS](https://console.aws.amazon.com/eks/home#/clusters) service
* Select **Clusters** from the side navigation menu.
* Select your cluster from the **Clusters** list.
* To delete **node groups**
    * On your **Kubernetes cluster** page, select the **Configuration** tab
    * Select **Compute** tab
    * Select the radio button on the left side of the node group name that you want to delete.
    * Select the **Delete** button on the top left of the **Node Groups** list.
    * On the pop-up displayed, type the `node group name` in the **To confirm the deletion, type the Node Group name in the field.** input field.
    * Click on the **Delete** button to delete the node group.
* To delete a cluster, return to the **Clusters** list, select the radio button on the left side of your cluster.
* Select the **Delete** from the top left.
* On the pop-up displayed, type `cluster name` in the **To confirm the deletion, type the cluster name in the field.** input field.
* Click on the **Delete** button to delete the EKS cluster. 


To remove the **EC2**, you can use the following steps.
* Open the Amazon [EC2](https://console.aws.amazon.com/ec2/) service
* In the navigation pane, Choose **Instances**
* From the **Instances** list, select the checkbox on the left side of the EC2 instance that you want to terminate.
* From the **Instance state** dropdown menu, select **Terminate instance**.
* On the pop-up box displayed, select **Terminate** to terminate the EC2 instance.

To remove **Route 53**, you can use the following steps.
* Open the Amazon [Route53](https://console.aws.amazon.com/route53/) service
* In the navigation pane, choose **Hosted zones**
* To delete hosted zone, you need to remove the additional record that was added.
    * Select the hosted zone from the **Hosted zones** list.
    * From the **Records** list, select the checkbox left of the additional record that is to be deleted.
    * Select the **Delete record** button on the top left of the **Records** list.
    * On the pop-up displayed select the **Delete** button to delete the record.
* Go back to the **Hosted zones** list, select the radio button on the left side of the zone that you want to delete.
* Select the **Delete** button from the top left of the list.
* On the pop-up displayed, type `delete` in the **To confirm that you want to delete the hosted zone, enter delete in the field.** input field.
* Click on the **Delete** button to delete the hosted zone.

To remove the **Route tables**, you can use the following steps.
* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, choose **Route Tables**
* Select the **Route table ID** of the route table you created.
* On the details pane, select the **Subnet association** tab
    * Select **Edit subnet association**
    * Uncheck all **Subnet Ids** that are selected.
    * Select **Save associations**
* Go back to route table list, select the check box near the route table you want to delete.
* Select *Delete route table* option from the **Actions** dropdown menu on the top right section of the list.
* On the pop-up displayed, type `delete` in the **To confirm the deletion, type delete in the field:** input field.
* Click on the **Delete** button to delete the route table.

To remove the **Nat gateway**, you can use the following steps.
* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, Select **NAT Gateways**
* From the list on **NAT Gateways**, select the checkbox of the NAT gateway that you created.
* Select **Delete NAT gateway** from the **Actions** dropdown menu.
* On the pop-up displayed, type `delete` in the **To confirm the deletion, type delete in the field:** input field.
* Click on the **Delete** button to delete the NAT gateway.


To remove the **Internet gateway**, you can use the following steps.
* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, Select **Internet Gateways**
* From the list on **Internet Gateways**, select the checkbox of the internet gateway you created.
* To detach the internet gateway from VPC before deleting it follow the below steps.
    * Select **Detach from VPC** option from the **Actions** dropdown menu on the top right section of the list to detach the internet gateway from VPC before deleting it.
    * On the pop-up displayed, select the **Detach internet gateway** button.
* Select **Delete Internet gateway** from the **Actions** dropdown menu.
* On the pop-up displayed, type `delete` in the **To confirm the deletion, type delete in the field:** input field.
* Click on the **Delete** button to delete the internet gateway.


To remove the **Subnets**, you can use the following steps.
* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, Select **Subnets**
* From the list on **Subnets**, select the checkbox of the subnets you created.
* Select **Delete subnet** option from the **Actions** dropdown menu on the top right section of the list.
* On the pop-up displayed, type `delete` in the **To confirm the deletion, type delete in the field:** input field.
* Click on the **Delete** button to delete the subnet.

To remove the **VPC**, you can use the following steps.
* Open the Amazon [VPC](https://console.aws.amazon.com/vpc/) service
* On the top-right of the navigation bar, select the AWS Region from the dropdown list.
* In the navigation pane, Select **Your VPCs**
* From the list on **Your VPCs**, select the checkbox of the VPC you created.
* Select **delete VPC** option from the **Actions** dropdown menu on the top right section of the list.
* On the pop-up displayed, type `delete` in the **To confirm the deletion, type delete in the field:** input field.
* Click on the **Delete** button to delete the VPC.

To remove the **IAM** role, you can use the following steps.
* Open the Amazon [IAM](https://console.aws.amazon.com/iam/) service
* In the navigation pane, select **Roles**
* From the **Roles** list, select the checkbox to the left of the role that you want to delete.
* Select the **Delete** button on the top left.
* On the pop-up displayed, type the name of the role to be deleted in **To confirm the deletion, enter the role name in the text input field.** input box.
* Select the **Delete** button on the pop-up to delete the IAM role.