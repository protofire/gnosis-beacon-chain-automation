variable "route53_ips_all" {
  type = map(object({
    route53_region = string
    health_check_path = string
    health_check_type = string
    ip = string
    dns = string
    name = string
    role = string
    rpc_port = string
  }))
  description = "Map of all AWS Route53 IP adresses"
}

variable "all_infra" {
  type = object({
    all_ips = map(object({
      role = string
      route53_region = string
      name = string
      provider = string
    }))
  })
}

variable "use_aws_route53_health_checks" {
  type = bool
  description = "Using AWS Route53 Health checks"
}

variable "hosted_zone" {
  type = string
  description = "Hosted zone name"
}

variable "hosted_zone_tag" {
  type = string
  description = "Hosted zone tag for resources"
}
