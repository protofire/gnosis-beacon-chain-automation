output "ebs_id" {
  description = "Show EBS ID"
  value       = aws_ebs_volume.ebs_volume.id
}

output "ebs_size" {
  description = "Show EBS size"
  value       = aws_ebs_volume.ebs_volume.size
}
