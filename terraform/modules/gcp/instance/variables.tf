variable "zone" {
  type        = string
  description = "Provide GCP zone"
}

variable "protoadmin_authorized_keys" {
  type = object({
    path_to_ansible_public_key  = string
    path_to_engineer_public_key = string
  })
  description = "Provide SSH public keys for prodoadmin user in authorized_keys file"
}

variable "instance" {
  type = object({
    name            = string
    hostname        = string
    compute_disk_id = string
    root_disk_size  = number
    tags            = list(string)
    machine_type    = string
    image           = string
    network         = string
    subnetwork      = string
    nat_ip_address  = string
  })
  description = "Provide GCP node parameters"
}
