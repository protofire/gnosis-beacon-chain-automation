output "instance_id" {
  description = "Show instance ID"
  value       = aws_instance.ec2.id
}

output "primary_network_interface_id" {
  description = "Show primary network interface ID"
  value = aws_instance.ec2.primary_network_interface_id
}
