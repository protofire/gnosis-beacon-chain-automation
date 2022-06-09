module "disk" {
  for_each = var.infra
  source            = "../modules/aws/disk"
  availability_zone = each.value.zone
  ebs = {
    name       = "${each.key}-${var.provider_name}-aws-data-volume"
    iops       = each.value.iops
    throughput = each.value.throughput
    size       = each.value.disk_size
  }
}
