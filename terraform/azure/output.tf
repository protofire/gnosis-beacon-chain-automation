output "instances_output" {
  description = "Show instance ID and external IP address"
  value = {for k,v in module.instance :
    k => {
      instance_id = v.instance_id
      external_ip = "${azurerm_public_ip.public_ip[k].ip_address}"
      external_dns = "${azurerm_public_ip.public_ip[k].fqdn}"
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
