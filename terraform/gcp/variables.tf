variable "infra" {
  type = map
  description = "Infrastructure"
}

variable "vm_config" {
  type = map(object({
    general = object({
      vm_name = string
      root_disk_size = number
      disk_size = number
      health_check_path = string
      health_check_type = string
      ports = map(list(string))
      target_tags = list(string)
    })
    provider_specific = map(object({}))
  }))
  description = "VM Config"
}

variable "provider_name" {
  type = string
  description = "Provider name"
}

variable "region" {
  type = string
  description = "Region"
}

variable "vpc_cidr_range" {
  type = string
  description = "VPC CIDR range"
}

variable "all_ips" {
  type = map
  description = "List of all IPs"
}

data "google_compute_image" "image" {
  project = "ubuntu-os-cloud"
  family = "ubuntu-2004-lts"
}

variable "security_options" {
  type = object({
    ssh_whitelist_ips = list(string)
    rpc_ws_whitelist_ips = list(string)
    health_check_ips = list(string)
    path_to_ansible_public_key = string
    path_to_engineer_public_key = string
  })
  description = "List of security options"
}

variable "use_aws_route53" {
  type = bool
  description = "Using AWS Route53 DNS for the GCP VM External IP address"
}

variable "hosted_zone" {
  type = string
  description = "Hosted zone name"
}
