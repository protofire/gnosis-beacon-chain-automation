resource "azurerm_managed_disk" "managed_disk" {
  name                 = var.managed_disk.name
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  zone                = var.resource_group.zone
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.managed_disk.disk_size_gb
}
