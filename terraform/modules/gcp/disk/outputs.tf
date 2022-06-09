output "compute_disk_id" {
  description = "Provide GCP disk ID"
  value       = google_compute_disk.disk.id
}
