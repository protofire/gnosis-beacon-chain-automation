variable "resource_group" {
  type = object({
    name     = string
    location = string
    zone = string
  })
  description = "Provide Azure resource group parameters"
}

variable "managed_disk" {
  type = object({
    name         = string
    disk_size_gb = number
  })
  description = "Provide Azure disk parameters"
}
