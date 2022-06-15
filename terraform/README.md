# infra-gbc-validator-terraform

This section of repository contains configurations, scripts and Terraform modules to deploy Gnosis Beacon Chain infrastructure.

Infrastructure parts to be deployed:
- Gnosis Chain nodes (GC nodes)
- Gnosis Beacon Chain nodes (GBC nodes)
- Gnosis Beacon Chain validators (GBC validators)

## TOC:
- [How to use](#how-to-use)
- [Configuration options](#configuration-options)

## How to use

1. Sign in to cloud providers:
    - <details>
      <summary><b>Azure</b></summary>
      <br>
      Sign in using Azure CLI:

      ```bash
      az login
      ```
      </details>

    - <details>
        <summary><b>Amazon Web Services (AWS)</b></summary>
        <br>
        You can use `AWS_ACCESS_KEY_ID`,  `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION` in command:

        ```bash
        aws configure
        ```

        or just export environment variables on your machine:

        ```bash
        export AWS_ACCESS_KEY_ID=some_access_key
        export AWS_SECRET_ACCESS_KEY=some_secret_access_key
        export AWS_DEFAULT_REGION=some_default_region
        ```
      </details>

    - <details>
        <summary><b>Google Cloud Platform (GCP)</b></summary>
        <br>
        Sign in using Google Cloud CLI:

        ```bash
        gcloud auth application-default login
        ```
      </details>

2.  *(Optional)* Configure parameters listed below in [`main.tf`](main.tf) file:
    -  The `backend "s3"` block defines an S3 bucket on AWS that is used to store `tfstate` remotely. You can remove this block entirely if you prefer to disable this behaviour.

3. Configure deployment parameters in [`terraform.tfvars.json`](terraform.tfvars.json) file.

    File [`terraform.tfvars.example.json`](terraform.tfvars.example.json) contains a sample configuration that deploys **1 GC node**, **1 GBC node** and **2 GBC validators** in all cloud providers (AWS, GCP, Azure). Use this file as a reference or navigate to [specification](#configuration-options) to learn more about available options. Single-cloud deployments are also available, refer to [specification](#cloudsprovideraccount).
    
    > **_NOTE:_** If you don't want to use AWS Route53 DNS records and/or health checks (default behariour), then you should set `false` to the following `use_aws_route53` and `use_aws_route53_health_checks` variables.

4. Regenerate Terraform code ([`main.tf.json`](main.tf.json) and [`locals.tf.json`](locals.tf.json)) based on your [`terraform.tfvars.json`](terraform.tfvars.json) using the following command:
    ```bash
    python ./create_infra.py
    ```

    > **_NOTE:_** You will have to run this command and the steps set out below after **any** subsequent changes made to `clouds` or `vm_config` blocks in [`terraform.tfvars.json`](terraform.tfvars.json)

5. Initialize a Terraform working directory:
    ```bash
    terraform init
    ```

6. Generate an execution plan:
    ```bash
    terraform plan
    ```

7. Deploy infrastructure:
    ```bash
    terraform apply
    ```

    Output of this command typically looks like this:
    ```
    all_ips = {
      "gbc_node" = [
        "15.42.121.85/32"
      ]
      "gbc_validator" = [
        "19.125.76.211/32"
      ]
      "gc_node" = [
        "23.41.202.206/32"
      ]
    }
    all_route53_ips = {
      "gbc_node" = {
        "gbc-node1-aws1-aws" = {
          "dns" = "ec2-15-42-121-85.eu-west-2.compute.amazonaws.com"
          "health_check_path" = "/lighthouse/health"
          "health_check_type" = "HTTP"
          "ip" = "15.42.121.85"
          "name" = "gbc-node1-aws1-aws"
          "role" = "gbc_node"
          "route53_region" = "eu-west-2"
          "rpc_port" = "5052"
        }
      }
      "gbc_validator" = {
        gbc-validator1-aws1-aws = {
          dns               = "ec2-19-125-76-211.eu-west-2.compute.amazonaws.com"
          health_check_path = "/lighthouse/health"
          health_check_type = "HTTP"
          ip                = "19.125.76.211"
          name              = "gbc-validator1-aws1-aws"
          role              = "gbc_validator"
          route53_region    = "eu-west-2"
          rpc_port          = "5052"
        }
      }
      "gc_node" = {
        "gc-node1-aws1-aws" = {
          "dns" = "ec2-23-41-202-206.eu-west-2.compute.amazonaws.com"
          "health_check_path" = "/health"
          "health_check_type" = "HTTP"
          "ip" = "23.41.202.206"
          "name" = "gc-node1-aws1-aws"
          "role" = "gc_node"
          "route53_region" = "eu-west-2"
          "rpc_port" = "8545"
        }
      }
    }
    instances_aws1 = tomap({
      "gbc-node1" = {
        "external_address" = "15.42.121.85"
        "external_dns" = "ec2-15-42-121-85.eu-west-2.compute.amazonaws.com"
        "instance_id" = "i-0b032e0aba8977602"
        "primary_network_interface_id" = "eni-034a9234e50589829"
      }
      "gbc-validator1" = {
        "external_address" = "19.125.76.211"
        "external_dns" = "ec2-19-125-76-211.eu-west-2.compute.amazonaws.com"
        "instance_id" = "i-0db6210c1a1d0e966"
        "primary_network_interface_id" = "eni-0879217ade7e961d6"
      }
      "gc-node1" = {
        "external_address" = "23.41.202.206"
        "external_dns" = "ec2-23-41-202-206.eu-west-2.compute.amazonaws.com"
        "instance_id" = "i-0359126d6c07cfd3c"
        "primary_network_interface_id" = "eni-08c3786221ac930d1"
      }
    })
    ```

    Note IP addresses from `all_ips` section. They will be needed to fill in Ansible inventory file to deploy the application.

## Configuration options


This section contains descriptions and notes regarding available configuration options meant to clarify their usage and the basic structure of configuration file.

### `сlouds`

> Required: yes
>
> Type: `block`

This block is a wrapper for all provider-related configurations. This block must contain only instances of [provider](#cloudsprovider).

### `clouds.<provider>`

> Required: yes
>
> Type: `block`
>
> Valid names: `aws`, `gcp`, `azure`

This block contains deployment configurations for a specific cloud provider. It is required that blocks for all valid cloud providers are present. This block must contain only instances of [account](#cloudsprovideraccount).

### `clouds.<provider>.<account>`

> Required: no
>
> Type: `block`
>
> Default: example1

This block contains deployment configuration for a specific cloud provider **in** a specific region.
In case you prefer the infrastructure to not be deployed in this provider, instances of this block can be ommited. Example:
```json
{
  "clouds": {
    "gcp": {}
  }
}
```

In case you want to deploy the infrastructure in multiple regions, create one instance of this block per region. Example:
```json
{
  "clouds": {
    "aws": {
      "deployment1": {
        "region": "eu-west-1"
      },
      "deployment2": {
        "region": "eu-west-2"
      }
    }
  }
}
```

### `clouds.<provider>.<account>.project`

> Required: yes
>
> Type: `parameter`
>
> Default: gnosis-validators

This parameter is a project name used by Google Cloud Platform and Microsoft Azure. It is not significant for Amazon Web Services but is also required for this provider for consistency.

### `clouds.<provider>.<account>.region`

> Required: yes
>
> Type: `parameter`
>
> Default: us-east-1

This parameter is a region in which resources will be deployed. Valid values for this parameter depend on cloud provider.

### `clouds.<provider>.<account>.route53_region`

> Required: yes
>
> Type: `parameter`
>
> Defalt: us-east-1

This parameter is used for AWS Route53 Latency routing. The general idea is to route user traffic from specified AWS region (e.g. `us-east-1`) to this deployment of your infrastructure. Use this parameter in pair with [region](#cloudsprovideraccountregion) to provide better proximity for customers.

### `clouds.<provider>.<account>.vpc_cidr_range`

> Required: yes
>
> Type: `parameter`
>
> Default: 10.0.0.0/16

This parameter defines CIDR block range to be used for the VPC.

### `clouds.<provider>.<account>.cidr_range`

> Required: yes
>
> Type: `parameter`
>
> Default: 10.0.0.0/24

This parameter defines CIDR block range to be used for subnets. Make sure that the octets included in the subnet mask are equal `0` (e.g. `172.1.0.0/24`)

### `clouds.<provider>.<account>.<role>`

> Required: yes
>
> Type: `block`
>
> Valid names: `gc_node`, `gbc_node`, `gbc_validator`

This block contains deployment configuration for the specified type of service.

### `clouds.<provider>.<account>.<role>.count`

> Required: yes
>
> Type: `parameter`
>
> Default: 1

This parameter defines count of instances to be deployed for the service specified in [role](#cloudsprovideraccountrole)

### `clouds.<provider>.<account>.<role>.zones`

> Reguired: yes
>
> Type: `parameter`
>
> Default: ["a"]

This parameter lists zones in which instances will be deployed. If less than `clouds.<provider>.<account>.<role>.count` zones are provided, then the last zone in the list will be used for the rest of instances. Example:

> `clouds.<provider>.<account>.<role>.count` = 3
>
> `clouds.<provider>.<account>.<role>.zones` = ["a", "b"]
>
>
> First instance will be deployed into zone `a`, and both second and third instances will be deployed into zone `b`

### `clouds.<provider>.<account>.<role>.custom_vm_config`

> Required: no
>
> Type: `block`

This block may contain the same parameters as [vm_config role](#vm_configrole). Parameters in this block (e.g. `vm_name`, `disk_size`) override those in `vm_config.<role>` for the deployment specified by `account` and `role`.

### `vm_config`

> Required: yes
>
> Type: `block`

This block contains default instance configurations for the specified types of services. This block must contain only instances of [vm_config.<role>](#vm_configrole) block. One block per each valid service type is required.

### `vm_config.<role>`

> Required: yes
>
> Type: `block`
>
> Valid names: `gc_node`, `gbc_node`, `gbc_validator`

This block contains instance configuration for the specified by `<role>` type of service.

### `vm_config.<role>.general`

> Required: yes
>
> Type: `block`

This block contains all cloud-agnostic instance parameters for the specified by `<role>` type of service.

### `vm_config.<role>.general.vm_name`

> Required: yes
>
> Type: `parameter`
>
> Default: `gc-node`, `gbc-node`, `gbc-validator` depending on service type

This parameter defines default instance name.

### `vm_config.<role>.general.root_disk_size`

> Required: yes
>
> Type: `parameter`
>
> Default: 30

This parameter defines the size of root disk. 
> NOTE: You can specify `10 GB` as default for all providers, but then you need to use `custom_vm_config` for the Azure provider to set `root_disk_size` to `30 GB` (for Ubuntu this is the minimum allowed disk size in Azure).

### `vm_config.<role>.general.disk_size`

> Required: yes
>
> Type: `parameter`
>
> Default: 100 for `gc_node`, 60 for `gbc_node`, 10 for `gbc_validator`

This parameter defines the size of disk mounted to `/data` where the application is stored.

### `vm_config.<role>.general.health_check_path`

> Required: yes
>
> Type: `parameter`
>
> Default: `/health` for `gc_node`, `/lighthouse/health` for `gbc_node`

This parameter defines path used by AWS Route53 Health Cheks when checking the application.

### `vm_config.<role>.general.health_check_type`

> Required: yes
>
> Type: `parameter`
>
> Default: HTTP

This parameter defines request type of AWS Route53 Health Cheks when checking the application

### `vm_config.<role>.general.ports.p2p`

> Required: yes
>
> Type: `parameter`
>
> Default: `["30303"]` for `gc_node`, `["9000"]` for `gbc_node`

This parameter lists P2P port(s) which are used to improve interaction with peers.

### `vm_config.<role>.general.ports.rpc`

> Required: yes
>
> Type: `parameter`
>
> Default: `["8545"]` for `gc_node`, `["5052"]` for `gbc_node`

This parameter lists JSON-RPC HTTP port(s) that will be open for the deployed instances.

### `vm_config.<role>.general.ws`

> Required: yes
>
> Type: `parameter`
>
> Default: `["8546"]` for `gc_node`, `["5052"]` for `gbc_node`

This parameter lists JSON-RPC WebSocket port(s) that will be open for the deployed instances.

### `vm_config.<role>.general.target_tags`

> Required: yes
>
> Type: `parameter`

This parameter lists tags that will be attached to the deployed resources.

### `vm_config.<role>.provider_specific`

> Required: yes
>
> Type: `block`

This block contains cloud-specific instance parameters for the specified by `<role>` type of service.

### `vm_config.<role>.provider_specific.<cloud>.vm_type`

> Required: yes
>
> Type: `parameter`

This parameter defines instance type for the specified by `<role>` type of service. Valid values for this parameter depend on cloud-provider specified by `cloud`.

### `vm_config.<role>.provider_specific.iops`

> Required: yes
>
> Type: `parameter`
>
> Default: 3000

This parameter defines required IOPS of the `gp3` disk. This parameter is significant for AWS deployments only.

### `vm_config.<role>.provider_specific.throughput`

> Required: yes
>
> Type: `parameter`
>
> Default: 125

This parameter defines required throughput of the `gp3` disk. This parameter is significant for AWS deployments only.

### `ssh_whitelist_ips`

> Required: yes
>
> Type: `parameter`
>
> Default: ["0.0.0.0/32"]

This parameter lists allowed IP address ranges from which you can connect to deployed instances using SSH.

### `rpc_ws_whitelist_ips`

> Required: yes
>
> Type: `parameter`
>
> Default: ["0.0.0.0/32"]

This parameter lists allowed IP address ranges that can access [JSON-RPC ports](#vm_config.<role>.general.ports.rpc).

### `path_to_ansible_public_key`

> Required: yes
>
> Type: `parameter`
>
> Default: ~/.ssh/ansible.pub

This parameter defines path to public key which will be used by Ansible to connect to deployed instances and deploy the application.

### `path_to_engineer_public_key`

> Required: yes
>
> Type: `parameter`
>
> Default: ~/.ssh/id_rsa.pub

This parameter defines path to public key which will be used by you (or any other responsible engineer) to connect to deployed instances for maintenance.

### `use_aws_route53`
  
> Required: yes
>
> Type: `parameter`
>
> Default: `true`
  
This parameter enables the creation of DNS records and health checks in AWS Route53.
  
### `use_aws_route53_health_checks`
 
> Required: yes
>
> Type: `parameter`
>
> Default: `true`

This parameter enables the creation of health checks in AWS Route53 and the addition of healt checkers to security groups of nodes. 
  
### `hosted_zone`

> Required: yes
>
> Type: `parameter`
>
> Default: example.com

This parameter defines Hosted Zone name for AWS Route53 to deploy DNS-records into.

### `hosted_zone_tag`

> Required: yes
>
> Type: `parameter`
>
> Default: gnosis

This parameter defines a tag that will be attached to all resource deployed into AWS Route53.

### `generate_ansible_inventory`

> Required: yes
>
> Type: `parameter`
>
> Default: `true`

This parameter enables the generation of an inventory file for Ansible.
