locals {
  security_options = {
    ssh_whitelist_ips = var.ssh_whitelist_ips
    rpc_ws_whitelist_ips = var.rpc_ws_whitelist_ips
    health_check_ips = (var.use_aws_route53_health_checks ? 
      data.aws_ip_ranges.health_checks_ips[0].cidr_blocks : [])

    path_to_ansible_public_key = var.path_to_ansible_public_key
    path_to_engineer_public_key = var.path_to_engineer_public_key
  }
  route53_roles = toset([for item, conf in local.ips :
    item if item != "gbc_validator" && conf != []
  ])
  route53_ips_all = merge(local.route53_ips.gc_node, local.route53_ips.gbc_node)
}

data "aws_ip_ranges" "health_checks_ips" {
  count = var.use_aws_route53_health_checks ? 1 : 0
  services = ["route53_healthchecks"]
}
