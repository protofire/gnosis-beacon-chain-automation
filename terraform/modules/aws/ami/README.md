<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ami.search](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amis_os_map_owners"></a> [amis\_os\_map\_owners](#input\_amis\_os\_map\_owners) | Map of amis owner to filter only official amis | `map(string)` | <pre>{<br>  "amazon": "137112412989",<br>  "amazon-2_lts": "137112412989",<br>  "centos": "679593333241",<br>  "centos-6": "679593333241",<br>  "centos-7": "679593333241",<br>  "centos-8": "679593333241",<br>  "debian": "679593333241",<br>  "debian-10": "136693071363",<br>  "debian-8": "679593333241",<br>  "debian-9": "679593333241",<br>  "fedora-27": "125523088429",<br>  "rhel": "309956199498",<br>  "rhel-6": "309956199498",<br>  "rhel-7": "309956199498",<br>  "rhel-8": "309956199498",<br>  "suse-les": "013907871322",<br>  "suse-les-12": "013907871322",<br>  "ubuntu": "099720109477",<br>  "ubuntu-14-04": "099720109477",<br>  "ubuntu-16-04": "099720109477",<br>  "ubuntu-18-04": "099720109477",<br>  "ubuntu-18-10": "099720109477",<br>  "ubuntu-19-04": "099720109477",<br>  "ubuntu-20-04": "099720109477"<br>}</pre> | no |
| <a name="input_amis_os_map_regex"></a> [amis\_os\_map\_regex](#input\_amis\_os\_map\_regex) | Map of regex to search amis | `map(string)` | <pre>{<br>  "amazon": "^amzn-ami-hvm-.*x86_64-gp2",<br>  "amazon-2_lts": "^amzn2-ami-hvm-.*x86_64-gp2",<br>  "centos": "^CentOS.Linux.7.*x86_64.*",<br>  "centos-6": "^CentOS.Linux.6.*x86_64.*",<br>  "centos-7": "^CentOS.Linux.7.*x86_64.*",<br>  "centos-8": "^CentOS.Linux.8.*x86_64.*",<br>  "debian": "^debian-stretch-.*",<br>  "debian-10": "^debian-10-.*",<br>  "debian-8": "^debian-jessie-.*",<br>  "debian-9": "^debian-stretch-.*",<br>  "fedora-27": "^Fedora-Cloud-Base-27-.*-gp2.*",<br>  "rhel": "^RHEL-7.*x86_64.*",<br>  "rhel-6": "^RHEL-6.*x86_64.*",<br>  "rhel-7": "^RHEL-7.*x86_64.*",<br>  "rhel-8": "^RHEL-8.*x86_64.*",<br>  "suse-les": "^suse-sles-12-sp\\d-v\\d{8}-hvm-ssd-x86_64",<br>  "suse-les-12": "^suse-sles-12-sp\\d-v\\d{8}-hvm-ssd-x86_64",<br>  "ubuntu": "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*",<br>  "ubuntu-14-04": "^ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-.*",<br>  "ubuntu-16-04": "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*",<br>  "ubuntu-18-04": "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*",<br>  "ubuntu-18-10": "^ubuntu/images/hvm-ssd/ubuntu-cosmic-18.10-amd64-server-.*",<br>  "ubuntu-19-04": "^ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-.*",<br>  "ubuntu-20-04": "^ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-.*"<br>}</pre> | no |
| <a name="input_amis_primary_owners"></a> [amis\_primary\_owners](#input\_amis\_primary\_owners) | Force the ami Owner, could be (self) or specific (id) | `string` | `""` | no |
| <a name="input_os"></a> [os](#input\_os) | The OS reference to search for | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The AMI id result of the search |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The owner id of the selected ami |
| <a name="output_root_device_name"></a> [root\_device\_name](#output\_root\_device\_name) | The device name of the root dev |
<!-- END_TF_DOCS -->