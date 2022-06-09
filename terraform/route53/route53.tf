resource "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone

  tags = {
    Environment = var.hosted_zone_tag
  }
}

resource "aws_route53_health_check" "health_check" {
  for_each = {for k, v in (
    var.use_aws_route53_health_checks ? var.all_infra.all_ips : {}
    ) : k => v
  }
  ip_address = var.route53_ips_all[each.key].ip
  port = var.route53_ips_all[each.key].rpc_port
  type = var.route53_ips_all[each.key].health_check_type
  resource_path = (var.route53_ips_all[each.key].health_check_type != "TCP" ? 
    var.route53_ips_all[each.key].health_check_path : null)
  failure_threshold = "5"
  request_interval = "30"

  tags = {
    Name = "${each.key}-health-check"
  }
}

resource "aws_route53_record" "gcp_dns_records" {
  for_each = {for k, v in var.all_infra.all_ips :
    k => v if v.provider == "gcp"
  }
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name = "${each.value.name}.${aws_route53_zone.hosted_zone.name}"
  type = "A"
  ttl = "300"
  records = [var.route53_ips_all[each.value.name].ip]
}

resource "aws_route53_record" "dns_records" {
  depends_on = [
    aws_route53_record.gcp_dns_records
  ]
  for_each = {for k, v in var.all_infra.all_ips :
    "${v.name}-${v.route53_region}" => v
  }
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name = "${replace(each.value.role, "_", "-")}.${aws_route53_zone.hosted_zone.name}"
  type = "CNAME"
  ttl = "300"
  records = [var.route53_ips_all[each.value.name].dns]
  set_identifier = each.key
  health_check_id = (var.use_aws_route53_health_checks ? 
    aws_route53_health_check.health_check[each.value.name].id : null)

  latency_routing_policy {
      region = each.value.route53_region
  }
}
