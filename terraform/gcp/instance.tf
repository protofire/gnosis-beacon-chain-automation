module "instance" {
  for_each = var.infra
  source = "../modules/gcp/instance"
  zone = each.value.zone
  protoadmin_authorized_keys = {
    path_to_ansible_public_key = var.security_options.path_to_ansible_public_key
    path_to_engineer_public_key = var.security_options.path_to_engineer_public_key
  }
  instance = {
    name = "${each.key}-${var.provider_name}-gcp"
    hostname = "${each.key}-${var.provider_name}-gcp"
    compute_disk_id = module.disk[each.key].compute_disk_id
    root_disk_size = each.value.root_disk_size
    tags = concat(
      ["${each.key}-${var.provider_name}-gcp"],
      var.vm_config[each.value.role].general.target_tags
    )
    machine_type = each.value.vm_type
    image = data.google_compute_image.image.id
    network = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.subnetwork[each.key].id
    nat_ip_address = google_compute_address.address[each.key].address
  }
}
