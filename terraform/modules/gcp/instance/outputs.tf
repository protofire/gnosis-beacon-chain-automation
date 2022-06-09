output "instance_id" {
  description = "Show GCP instance ID"
  value       = google_compute_instance.instance.id
}

output "external_ip" {
  description = "Show external IP for instance"
  value       = google_compute_instance.instance.network_interface.0.access_config.0.nat_ip
}
