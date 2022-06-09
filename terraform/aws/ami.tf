module "ami" {
  for_each = var.infra
  source = "../modules/aws/ami"
  os = "ubuntu-20-04"
}
