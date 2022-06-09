module "instance" {
  for_each = var.infra
  source = "../modules/azure/instance"
  resource_group = {
    name     = var.resource_group_name
    location = var.region
    zones    = [each.value.zone]
  }
  protoadmin_authorized_keys = {
    path_to_engineer_public_key = var.security_options.path_to_ansible_public_key
    path_to_ansible_public_key  = var.security_options.path_to_engineer_public_key
  }
  virtual_machine = {
    name                             = "${each.key}-${var.provider_name}-azure"
    hostname                         = "${each.key}-${var.provider_name}-azure"
    vm_size                          = each.value.vm_type
    root_disk_size                   = each.value.root_disk_size
    managed_disk_id                  = module.disk[each.key].managed_disk_id
    network_interface_id             = azurerm_network_interface.network_interface[each.key].id
    source_image_reference_publisher = "Canonical"
    source_image_reference_offer     = "0001-com-ubuntu-server-focal"
    source_image_reference_sku       = "20_04-lts-gen2"
    source_image_reference_version   = "latest"
  }
}
