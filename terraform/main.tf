terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source = "hashicorp/google"
      version = ">= 3.0.0"
    }
  }
  backend "s3" { 
    bucket = "example-bucket-tfstate"
    profile = "aws-profile-used-for-route53"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

resource "local_file" "ansible_inventory" {
  count = var.generate_ansible_inventory ? 1 : 0
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      route53_ips = local.route53_ips
      admin_user = "protoadmin"
      path_to_ansible_public_key = replace(
        var.path_to_ansible_public_key, ".pub", "")
    }
  )
  filename = "../ansible/inventories/hosts.yml"
  file_permission = "0644"
}

module "route53" {
  count = var.use_aws_route53 ? 1 : 0
  source = "./route53"

  route53_ips_all = local.route53_ips_all
  all_infra = local.all-infra

  use_aws_route53_health_checks = var.use_aws_route53_health_checks

  hosted_zone = var.hosted_zone
  hosted_zone_tag = var.hosted_zone_tag
}
