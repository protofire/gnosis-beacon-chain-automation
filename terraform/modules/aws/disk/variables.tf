variable "availability_zone" {
  type        = string
  description = "Specifry availability zone"
}

variable "ebs" {
  type = object({
    name       = string
    iops       = string
    throughput = string
    size       = number
  })
  default     = null
  description = "Provide AWS EBS volume parameters"
}
