module "disk" {
  for_each = var.infra
  source = "../modules/azure/disk"
  resource_group = {
    name     = var.resource_group_name
    location = var.region
    zone = each.value.zone
  }
  managed_disk = {
    disk_size_gb = each.value.disk_size
    name = "${each.key}-${var.provider_name}-azure-data-volume"
  }
}
