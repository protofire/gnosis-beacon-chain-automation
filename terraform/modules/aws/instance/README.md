<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_volume_attachment.volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [template_file.init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Specifry availability zone | `string` | n/a | yes |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | Provide EC2 instance parameters | <pre>object({<br>    name            = string<br>    ami             = string<br>    instance_type   = string<br>    hostname        = string<br>    ebs_volume_id   = string<br>    ebs_device_name = string<br>    subnet_id       = string<br>    sg_id           = string<br>  })</pre> | n/a | yes |
| <a name="input_protoadmin_authorized_keys"></a> [protoadmin\_authorized\_keys](#input\_protoadmin\_authorized\_keys) | Provide path to SSH public keys for prodoadmin user in authorized\_keys file | <pre>object({<br>    path_to_ansible_public_key  = string<br>    path_to_engineer_public_key = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_address"></a> [external\_address](#output\_external\_address) | Show external IP address |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Show instance ID |
<!-- END_TF_DOCS -->