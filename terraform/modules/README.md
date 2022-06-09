## Amazon Web Services (AWS)

Here you can see Amazon Web Services (AWS) module with described module sections. Module consist of three sections:

* [Instance](./aws/instance)

* [AMI](./aws/ami)

* [Disk](./aws/disk)

* [Network](./aws/network)

### Instance

This module section allow us create AWS EC2 instance with SSH username and public key. Also resource has `init.tf` for init script which create general user and do some manipulations with additional volume.

> `Note`: by default in AWS EC2 instance username is `protoadmin` where we should specify Ansible SSH public key and engineer SSH public key, who create resources!

### AMI

This module section allow us choose OS for our instance. Please check [README.md](./aws/ami/README.md) for more information.

### Disk

This module section allow us create AWS EBS disk for additional volume for blockchain data.

### Network

This module section allow us crete AWS VPC, Subnet for VPC, public IP, Security Group and bunch of Security Group rules for specific blockchain.

## Microsoft Azure

Here you can see Microsoft Azure module with described module sections. Module consist of three sections:

* [Instance](./azure/instance)

* [Disk](./azure/disk)

* [Network](./azure/network)

### Instance

This module section allow us create Azure Linux virtual machine instance with SSH username and public key. Also resource has `init.tf` for init script which create general user and do some manipulations with additional volume.

> `Note`: by default in Azure Virtual machine username is `protoadmin` where we should specify Ansible SSH public key and engineer SSH public key, who create resources!

### Disk

This module section allow us create Azure managed disk for additional volume for blockchain data.

### Network

This module section allow us crete Azure Virtual network, sub - network, public IP, Security Group and bunch of Security Group rules for specific blockchain.

## Google Cloud Platform (GCP)

Here you can see Google Cloud Platform (GCP) module with described module sections. Module consist of three sections:

* [Instance](./gcp/instance)

* [Disk](./gcp/disk)

* [Network](./gcp/network)

### Instance

This module section allow us create GCP compute instance with SSH username and public key. Also resource has `init.tf` for init script which create general user and do some manipulations with additional volume.

> `Note`: by default in GCP compute instance username is `protoadmin` where we should specify Ansible SSH public key and engineer SSH public key, who create resources!

### Disk

This module section allow us create GCP compute disk for additional volume for blockchain data.

### Network

This module section allow us crete GCP network, sub - network, public IP and bunch of network firewall rules for specific blockchain.

# How to contribute

If you want to update cloud provider module you should create Issue with next description:

```bash
[Cloud provider] module: [issue title]

[Issue description]
```

Next create PR with next description:

```bash

feat: [Cloud provider] module - [PR title]

- Related issue - [issue/purpose description]

- What we did - [manipulations description]

```

and pin to created issue.
