variable "availability_zone" {
  type        = string
  description = "Specifry availability zone"
}

variable "protoadmin_authorized_keys" {
  type = object({
    path_to_ansible_public_key  = string
    path_to_engineer_public_key = string
  })
  description = "Provide path to SSH public keys for prodoadmin user in authorized_keys file"
}

variable "ec2" {
  type = object({
    name            = string
    ami             = string
    instance_type   = string
    hostname        = string
    ebs_volume_id   = string
    ebs_device_name = string
    ebs_disk_size   = number
    subnet_id       = string
  })
  description = "Provide EC2 instance parameters"
}
