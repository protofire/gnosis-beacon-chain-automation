output "instances_output" {
  description = "Show instance ID and external IP address"
  value = {for k, v in module.instance : 
    k => {
      instance_id = v.instance_id
      external_ip = google_compute_address.address[k].address
      external_dns = (var.use_aws_route53 ?
        "${k}-${var.provider_name}-gcp.${var.hosted_zone}" :
        "${google_compute_address.address[k].address}"
      )
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
