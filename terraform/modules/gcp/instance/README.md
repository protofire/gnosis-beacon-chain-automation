<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_attached_disk.attached_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_instance.instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [template_file.init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance"></a> [instance](#input\_instance) | Provide GCP node parameters | <pre>object({<br>    name            = string<br>    hostname        = string<br>    compute_disk_id = string<br>    tags            = list(string)<br>    machine_type    = string<br>    image           = string<br>    network         = string<br>    subnetwork      = string<br>    nat_ip_address  = string<br>  })</pre> | n/a | yes |
| <a name="input_protoadmin_authorized_keys"></a> [protoadmin\_authorized\_keys](#input\_protoadmin\_authorized\_keys) | Provide SSH public keys for prodoadmin user in authorized\_keys file | <pre>object({<br>    path_to_ansible_public_key  = string<br>    path_to_engineer_public_key = string<br>  })</pre> | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Provide GCP zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ip"></a> [external\_ip](#output\_external\_ip) | Show external IP for instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Show GCP instance ID |
<!-- END_TF_DOCS -->