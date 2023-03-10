# Configure Scalar DL Auditor mode for network peering

This document explains how to connect multiple private networks for ScalarDL Auditor mode to perform network peering. For ScalarDL Auditor mode to work properly, you must connect ScalarDL Ledger to ScalarDL Auditor.

## Private networks to connect

Depending on your application (client) deployment, you must connect multiple private networks.

### Connect two private networks

If you deploy your application (client) on the same private network as ScalarDL Ledger or ScalarDL Auditor, you must connect two private networks.

* [ScalarDL Ledger network] <-> [ScalarDL Auditor network]

### Connect three private networks

If you deploy your application (client) on a separate private network away from ScalarDL Ledger or ScalarDL Auditor, you must connect three private networks.

* [ScalarDL Ledger network] <-> [ScalarDL Auditor network]
* [ScalarDL Ledger network] <-> [application (client) network]
* [ScalarDL Auditor network] <-> [application (client) network]

## Network requirements

### IP address ranges

To avoid conflicting IP addresses between the private networks, you must have private networks with different IP address ranges. For example:

* **Private network for ScalarDL Ledger:** 10.1.0.0/16
* **Private network for ScalarDL Auditor:** 10.2.0.0/16
* **Private network for application (client):** 10.3.0.0/16

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

Private-network peering

### Amazon VPC peering

For details on how to peer virtual private clouds (VPCs) in an Amazon Web Services (AWS) environment, see the official documentation from Amazon at [Create a VPC peering connection](https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html).

### Azure VNet peering

For details on how to peer virtual networks in an Azure environment, see the official documentation from Microsoft at [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview).

