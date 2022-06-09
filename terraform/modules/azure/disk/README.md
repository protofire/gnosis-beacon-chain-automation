<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed_disk"></a> [managed\_disk](#input\_managed\_disk) | Provide Azure disk parameters | <pre>object({<br>    name         = string<br>    disk_size_gb = number<br>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Provide Azure resource group parameters | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_disk_id"></a> [managed\_disk\_id](#output\_managed\_disk\_id) | Show additional disk ID |
<!-- END_TF_DOCS -->