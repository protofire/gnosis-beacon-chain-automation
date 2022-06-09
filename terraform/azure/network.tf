locals {
  roles = toset([for item in var.infra : item.role])
  ips = { for role in local.roles : role => [
      for k, v in var.infra : 
        "${azurerm_public_ip.public_ip[k].ip_address}/32" if role == v.role
    ]
  }
  route53_ips = { for role in local.roles :
    role => {
      for k, v in var.infra :
        "${k}-${var.provider_name}-azure" => {
          name = "${k}-${var.provider_name}-azure"
          ip = "${azurerm_public_ip.public_ip[k].ip_address}"
          dns = "${azurerm_public_ip.public_ip[k].fqdn}"
          route53_region = v.route53_region
          role = v.role
          rpc_port = element(v.ports.rpc, 0)
          health_check_path = v.health_check_path
          health_check_type = v.health_check_type
        } if role == v.role
    }
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "gnosis-${var.provider_name}-azure-network"
  address_space       = [var.vpc_cidr_range]
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = var.infra
  name                 = "${each.key}-${var.provider_name}-azure-subnetwork"
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [each.value.cidr_range]
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "public_ip" {
  for_each = var.infra
  name                = "${each.key}-${var.provider_name}-azure-public-ip"
  allocation_method   = "Static"
  location            = var.region
  domain_name_label   = "${each.key}-${var.provider_name}"
  resource_group_name = var.resource_group_name
  zones               = [each.value.zone]
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "network_security_group" {
  for_each = local.roles
  name                = "${each.key}-${var.provider_name}-azure-network-sg"
  location            = var.region
  resource_group_name = var.resource_group_name
}

# Specify default SSH rule for connection via Altros VPN

resource "azurerm_network_security_rule" "firewall_rule_allow_ssh" {
  for_each = local.roles
  name                        = "allow-ssh"
  description                 = "Allow SSH port"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.security_options.ssh_whitelist_ips
  destination_address_prefix  = "*"
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group[each.key].name
}

resource "azurerm_network_security_rule" "firewall_rule_allow_p2p" {
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name                        = "allow-p2p"
  description                 = "Allow RPC ports"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = var.vm_config[each.key].general.ports.p2p
  source_address_prefixes     = ["0.0.0.0/0"]
  destination_address_prefix  = "*"
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group[each.key].name
}

resource "azurerm_network_security_rule" "firewall_rule_allow_rpc" {
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name                        = "allow-rpc"
  description                 = "Allow RPC ports"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = var.vm_config[each.key].general.ports.rpc
  source_address_prefixes     = concat(
    var.security_options.rpc_ws_whitelist_ips,
    var.security_options.health_check_ips,
    each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
  )
  destination_address_prefix  = "*"
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group[each.key].name
}

resource "azurerm_network_security_rule" "firewall_rule_allow_ws" {
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name                        = "allow-ws"
  description                 = "Allow RPC ports"
  priority                    = 115
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = var.vm_config[each.key].general.ports.ws
  source_address_prefixes     = concat(
    var.security_options.rpc_ws_whitelist_ips,
    var.security_options.health_check_ips,
    each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
  )
  destination_address_prefix  = "*"
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group[each.key].name
}

resource "azurerm_network_interface" "network_interface" {
  for_each = var.infra
  name                = "${each.key}-${var.provider_name}-azure-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "security_group_association" {
  for_each = var.infra
  network_interface_id      = azurerm_network_interface.network_interface[each.key].id
  network_security_group_id = azurerm_network_security_group.network_security_group[var.infra[each.key].role].id
}
