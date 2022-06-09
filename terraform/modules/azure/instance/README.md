<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine.virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [template_file.init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_protoadmin_authorized_keys"></a> [protoadmin\_authorized\_keys](#input\_protoadmin\_authorized\_keys) | Provide SSH public keys for prodoadmin user in authorized\_keys file | <pre>object({<br>    path_to_ansible_public_key  = string<br>    path_to_engineer_public_key = string<br>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Provide Azure resource group parameters | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | n/a | yes |
| <a name="input_virtual_machine"></a> [virtual\_machine](#input\_virtual\_machine) | Provide Azure Linux VM parameters | <pre>object({<br>    name                             = string<br>    hostname                         = string<br>    managed_disk_id                  = string<br>    vm_size                          = string<br>    network_interface_id             = string<br>    source_image_reference_publisher = string<br>    source_image_reference_offer     = string<br>    source_image_reference_sku       = string<br>    source_image_reference_version   = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Show instance ID |
<!-- END_TF_DOCS -->