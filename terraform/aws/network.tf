locals {
  roles = toset([for item in var.infra : item.role])
  ips = { for role in local.roles : role => [
      for k, v in var.infra : 
        "${aws_eip.eip[k].public_ip}/32" if role == v.role
    ]
  }
  route53_ips = { for role in local.roles :
    role => {
      for k, v in var.infra :
        "${k}-${var.provider_name}-aws" => {
          name = "${k}-${var.provider_name}-aws"
          ip = "${aws_eip.eip[k].public_ip}"
          dns = "${aws_eip.eip[k].public_dns}"
          route53_region = v.route53_region
          role = v.role
          rpc_port = element(v.ports.rpc, 0)
          health_check_path = v.health_check_path
          health_check_type = v.health_check_type
        } if role == v.role
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_range
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "gnosis-${var.provider_name}-aws-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gnosis-${var.provider_name}-aws-gw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "gnosis-${var.provider_name}-aws-route-table"
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.infra
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_range
  availability_zone       = each.value.zone

  tags = {
    Name = "${each.key}-${var.provider_name}-aws-subnet"
  }
}

resource "aws_route_table_association" "route_table_associtation" {
  for_each = var.infra
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_eip" "eip" {
  for_each = var.infra
  instance = module.instance[each.key].instance_id
  vpc      = true
}


resource "aws_security_group" "allow-ssh-p2p-sg" {
  for_each = local.roles
  name        = "${each.key}-${var.provider_name}-allow-ssh-p2p-aws-sg"
  description = "Security group for ${each.key}-${var.provider_name}"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [22]

    content {
      from_port         = ingress.value
      to_port           = ingress.value
      protocol          = "tcp"
      cidr_blocks       = var.security_options.ssh_whitelist_ips
      description       = "Allow SSH port"
    }
  }

  dynamic "ingress" {
    for_each = each.key != "gbc_validator" ? var.vm_config[each.key].general.ports.p2p : []

    content {
      from_port         = ingress.value
      to_port           = ingress.value
      protocol          = "tcp"
      cidr_blocks       = ["0.0.0.0/0"]
      description       = "Allow P2P ports"
    }
  }

  dynamic "ingress" {
    for_each = each.key != "gbc_validator" ? var.vm_config[each.key].general.ports.p2p : []

    content {
      from_port         = ingress.value
      to_port           = ingress.value
      protocol          = "udp"
      cidr_blocks       = ["0.0.0.0/0"]
      description       = "Allow P2P ports"
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    description      = "Allow egress traffic"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${each.key}-${var.provider_name}-aws-sg"
  }
}

resource "aws_network_interface_sg_attachment" "attach-allow-ssh-p2p-sg" {
  for_each = var.infra
  security_group_id = aws_security_group.allow-ssh-p2p-sg[each.value.role].id
  network_interface_id = module.instance[each.key].primary_network_interface_id
}


resource "aws_security_group" "allow-rpc-sg" {
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name        = "${each.key}-${var.provider_name}-allow-rpc-aws-sg"
  description = "Security group for ${each.key}-${var.provider_name}"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.vm_config[each.key].general.ports.rpc
 
    content {
      from_port         = ingress.value
      to_port           = ingress.value
      protocol          = "tcp"
      cidr_blocks = concat(
        var.security_options.rpc_ws_whitelist_ips,
        var.security_options.health_check_ips,
        each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
      )
      description       = "Allow RPC ports"
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    description      = "Allow egress traffic"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${each.key}-${var.provider_name}-aws-sg"
  }
}

resource "aws_network_interface_sg_attachment" "attach-allow-rpc-sg" {
  for_each = toset([
    for instance, conf in var.infra : instance if var.infra[instance].role != "gbc_validator"
  ])
  security_group_id = aws_security_group.allow-rpc-sg[var.infra[each.key].role].id
  network_interface_id = module.instance[each.key].primary_network_interface_id
}

resource "aws_security_group" "allow-ws-sg" {
  for_each = toset([
    for role in local.roles : role if (
      role != "gbc_validator" &&
      var.vm_config[role].general.ports.rpc != var.vm_config[role].general.ports.ws)
  ])
  name        = "${each.key}-${var.provider_name}-allow-ws-aws-sg"
  description = "Security group for ${each.key}-${var.provider_name}"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.vm_config[each.key].general.ports.ws
 
    content {
      from_port         = ingress.value
      to_port           = ingress.value
      protocol          = "tcp"
      cidr_blocks = concat(
        var.security_options.rpc_ws_whitelist_ips,
        var.security_options.health_check_ips,
        each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
      )
      description       = "Allow WS ports"
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    description      = "Allow egress traffic"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${each.key}-${var.provider_name}-aws-sg"
  }
}

resource "aws_network_interface_sg_attachment" "attach-allow-ws-sg" {
  for_each = toset([
    for instance, conf in var.infra : instance if (
      var.infra[instance].role != "gbc_validator" &&
      var.vm_config[conf.role].general.ports.rpc != var.vm_config[conf.role].general.ports.ws)
  ])
  security_group_id = aws_security_group.allow-ws-sg[var.infra[each.key].role].id
  network_interface_id = module.instance[each.key].primary_network_interface_id
}
