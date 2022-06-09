resource "azurerm_virtual_machine" "virtual_machine" {
  name                  = var.virtual_machine.name
  resource_group_name   = var.resource_group.name
  location              = var.resource_group.location
  zones                 = var.resource_group.zones
  network_interface_ids = [var.virtual_machine.network_interface_id]
  vm_size               = var.virtual_machine.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = var.virtual_machine.name
    admin_username = "protoadmin"
    custom_data    = data.template_file.init.rendered
  }

  storage_image_reference {
    publisher = var.virtual_machine.source_image_reference_publisher
    offer     = var.virtual_machine.source_image_reference_offer
    sku       = var.virtual_machine.source_image_reference_sku
    version   = var.virtual_machine.source_image_reference_version
  }

  storage_os_disk {
    name              = "${var.virtual_machine.name}-os-disk"
    disk_size_gb      = var.virtual_machine.root_disk_size
    os_type           = "Linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("${var.protoadmin_authorized_keys.path_to_engineer_public_key}")
      path     = "/home/protoadmin/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_data_disk_attachment" {
  managed_disk_id    = var.virtual_machine.managed_disk_id
  virtual_machine_id = azurerm_virtual_machine.virtual_machine.id
  lun                = "10"
  caching            = "ReadWrite"
}
