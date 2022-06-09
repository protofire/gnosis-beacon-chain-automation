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
| [aws_ebs_volume.ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Specifry availability zone | `string` | n/a | yes |
| <a name="input_ebs"></a> [ebs](#input\_ebs) | Provide AWS EBS volume parameters | <pre>object({<br>    name       = string<br>    iops       = string<br>    throughput = string<br>    size       = number<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_id"></a> [ebs\_id](#output\_ebs\_id) | Show EBS ID |
| <a name="output_ebs_size"></a> [ebs\_size](#output\_ebs\_size) | Show EBS size |
<!-- END_TF_DOCS -->