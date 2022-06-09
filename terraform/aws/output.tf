output "instances_output" {
  description = "Show instance ID and external IP address"
  value = {for k, v in module.instance:
    k => {
      instance_id = v.instance_id
      primary_network_interface_id = v.primary_network_interface_id
      external_address = aws_eip.eip[k].public_ip
      external_dns = aws_eip.eip[k].public_dns
    }
  }
}

output "ips" {
  description = "List of provider IPs"
  value = local.ips
}

output "route53_ips" {
  description = "List of provider IPs for Route53"
  value = local.route53_ips
}
