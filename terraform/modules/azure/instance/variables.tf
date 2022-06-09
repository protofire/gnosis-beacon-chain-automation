variable "resource_group" {
  type = object({
    name     = string
    location = string
    zones    = list(string)
  })
  description = "Provide Azure resource group parameters"
}

variable "protoadmin_authorized_keys" {
  type = object({
    path_to_ansible_public_key  = string
    path_to_engineer_public_key = string
  })
  description = "Provide SSH public keys for prodoadmin user in authorized_keys file"
}

variable "virtual_machine" {
  type = object({
    name                             = string
    hostname                         = string
    managed_disk_id                  = string
    root_disk_size                   = number
    vm_size                          = string
    network_interface_id             = string
    source_image_reference_publisher = string
    source_image_reference_offer     = string
    source_image_reference_sku       = string
    source_image_reference_version   = string
  })
  description = "Provide Azure Linux VM parameters"
}
