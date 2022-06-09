module "instance" {
  for_each = var.infra
  source            = "../modules/aws/instance"
  availability_zone = each.value.zone
  protoadmin_authorized_keys = {
    path_to_ansible_public_key = var.security_options.path_to_ansible_public_key
    path_to_engineer_public_key = var.security_options.path_to_engineer_public_key
  }
  ec2 = {
    name            = "${each.key}-${var.provider_name}-aws"
    hostname        = "${each.key}-${var.provider_name}-aws"
    ami             = module.ami[each.key].ami_id
    instance_type   = each.value.vm_type
    ebs_device_name = "/dev/nvme1n1"
    ebs_volume_id   = module.disk[each.key].ebs_id
    ebs_disk_size   = each.value.root_disk_size
    subnet_id       = aws_subnet.subnet[each.key].id
  }
}
