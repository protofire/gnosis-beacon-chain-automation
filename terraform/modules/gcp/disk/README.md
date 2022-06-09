<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disk"></a> [disk](#input\_disk) | Provide GCP disk parameters | <pre>object({<br>    name = string<br>    size = number<br>  })</pre> | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Provide GCP zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_disk_id"></a> [compute\_disk\_id](#output\_compute\_disk\_id) | Provide GCP disk ID |
<!-- END_TF_DOCS -->