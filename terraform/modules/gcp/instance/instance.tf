resource "google_compute_instance" "instance" {
  name         = var.instance.name
  machine_type = var.instance.machine_type
  zone         = var.zone

  tags = var.instance.tags

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.instance.image
      size  = var.instance.root_disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = var.instance.network
    subnetwork = var.instance.subnetwork
    access_config {
      nat_ip = var.instance.nat_ip_address
    }
  }

  lifecycle {
    ignore_changes = [
      attached_disk, 
      boot_disk.0.initialize_params.0.image
    ]
  }

  metadata = {
    startup-script = data.template_file.init.rendered
  }
}

resource "google_compute_attached_disk" "attached_disk" {
  device_name = "data"
  disk        = var.instance.compute_disk_id
  instance    = google_compute_instance.instance.id
}
