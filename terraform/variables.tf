############################## Cloud provider specific variables ##############################

variable "clouds" {
  type = map(map(object({
    project = string
    region = string
    route53_region = string
    vpc_cidr_range = string
    cidr_range = string
    gc_node = object({
      count = number
      zones = list(string)
    })
    gbc_node = object({
      count = number
      zones = list(string)
    })
    gbc_validator = object({
      count = number
      zones = list(string)
    })
  })))
  description = "Providers scheme config"
}

############################## Cloud agnostic variables ##############################
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

## ACL
variable "ssh_whitelist_ips" {
  type = list(string)
  description = "List of IPs addresses with SSH access"
}

variable "rpc_ws_whitelist_ips" {
  type = list(string)
  description = "List of IPs able to access RPC port"
}

## Public keys
variable "path_to_ansible_public_key" {
  type = string
  description = "Public SSH key used by Ansible"
}

variable "path_to_engineer_public_key" {
  type = string
  description = "Public SSH key used by Engineer"
}

## AWS Route53
variable "use_aws_route53" {
  type = bool
  description = "Using AWS Route53 DNS and Health checks"
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

variable "generate_ansible_inventory" {
  type = bool
  description = "Generating an inventory file for Ansible"
}
