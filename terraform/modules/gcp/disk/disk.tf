resource "google_compute_disk" "disk" {
  name                      = var.disk.name
  type                      = "pd-ssd"
  zone                      = var.zone
  size                      = var.disk.size
  physical_block_size_bytes = 4096
}
