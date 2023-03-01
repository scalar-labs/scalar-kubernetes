# Create network peering for Scalar DL Auditor mode

This document explains how to connect several private networks for ScalarDL Auditor mode. To make ScalarDL Auditor mode work properly, ScalarDL Ledger and ScalarDL Auditor need to connect with each other. 

## Private network you must connect

Depending on your application (client) deployment, you must connect several private networks.

### Connect two private networks

If you deploy your application on the same private network as ScalarDL Ledger or ScalarDL Auditor, you must connect two private networks.

* [ScalarDL Ledger network] <-> [ScalarDL Auditor network]

### Connect three private networks

If you deploy your application (client) on another private network than ScalarDL Ledger or ScalarDL Auditor, you must connect three private networks.

* [ScalarDL Ledger network] <-> [ScalarDL Auditor network]
* [ScalarDL Ledger network] <-> [Application (client) network]
* [ScalarDL Auditor network] <-> [Application (client) network]

## Network requirements

### IP address ranges

To avoid conflicting IP addresses between several private networks, you must create several private networks with different IP address ranges.

* Example
    * Private network for ScalarDL Ledger -> 10.1.0.0/16
    * Private network for ScalarDL Auditor -> 10.2.0.0/16
    * Private network for application (client) -> 10.3.0.0/16

### Connections

The connections (ports) that are used between ScalarDL Ledger, ScalarDL Auditor, and the client by default are the following. You must allow these connections between each private network. Note that if you change the listening port of ScalarDL in a configuration file ([ledger|auditor].properties) from default, you must allow the connections using the port you configured.

* Scalar DL Ledger
    * 50051/TCP (Accept the requests from a client and Auditor)
    * 50052/TCP (Accept the privileged requests from a client and Auditor)
* Scalar DL Auditor
    * 40051/TCP (Accept the requests from a client and Ledger)
    * 40052/TCP (Accept the privileged requests from a client and Ledger)
* Scalar Envoy (Used with Scalar DL Ledger and Scalar DL Auditor)
    * 50051/TCP (Load balancing for Scalar DL Ledger)
    * 50052/TCP (Load balancing for Scalar DL Ledger)
    * 40051/TCP (Load balancing for Scalar DL Auditor)
    * 40052/TCP (Load balancing for Scalar DL Auditor)

## How to peer the private networks

### AWS (VPC peering)

Please refer to the following official document for more details on how to peer the VPCs in the AWS environment.

* [Create a VPC peering connection](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html)

### Azure (Virtual network peering)

Please refer to the following official document for more details on how to peer the VNets in the Azure environment.

* [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
