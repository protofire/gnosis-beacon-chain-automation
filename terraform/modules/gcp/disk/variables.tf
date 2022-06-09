variable "zone" {
  type        = string
  description = "Provide GCP zone"
}

variable "disk" {
  type = object({
    name = string
    size = number
  })
  description = "Provide GCP disk parameters"
}
