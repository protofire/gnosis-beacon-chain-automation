module "disk" {
  for_each = var.infra
  source = "../modules/gcp/disk"
  zone = each.value.zone
  disk = {
    name = "${each.key}-${var.provider_name}-gcp-data-volume"
    size = each.value.disk_size
  }
}
