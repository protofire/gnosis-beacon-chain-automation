locals {
  roles = toset([for item in var.infra : item.role])
  ips = { for role in local.roles : role => [
      for k, v in var.infra : 
        "${google_compute_address.address[k].address}/32" if role == v.role
    ]
  }
  route53_ips = { for role in local.roles :
    role => {
      for k, v in var.infra :
        "${k}-${var.provider_name}-gcp" => {
          name = "${k}-${var.provider_name}-gcp"
          ip = "${google_compute_address.address[k].address}"
          dns = (var.use_aws_route53 ?
            "${k}-${var.provider_name}-gcp.${var.hosted_zone}" :
            "${google_compute_address.address[k].address}"
          )
          route53_region = v.route53_region
          role = v.role
          rpc_port = element(v.ports.rpc, 0)
          health_check_path = v.health_check_path
          health_check_type = v.health_check_type
        } if role == v.role
    }
  }
}

resource "google_compute_network" "network" {
  name = replace("gnosis-${var.provider_name}-gcp-network", "_", "-")
  auto_create_subnetworks = false
  mtu                     = 1500
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.infra
  name = replace("${each.key}-${var.provider_name}-gcp-subnetwork", "_", "-")
  ip_cidr_range = each.value.cidr_range
  region        = var.region
  network       = google_compute_network.network.id
}

resource "google_compute_address" "address" {
  for_each = var.infra
  name = replace("${each.key}-static-external-address", "_", "-")
  region = var.region
}

resource "google_compute_firewall" "firewall_rule_allow_ssh" {
  for_each = local.roles
  name        = replace("${each.key}-${var.provider_name}-allow-ssh", "_", "-")
  network     = google_compute_network.network.id
  description = "Allow SSH port"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = var.vm_config[each.key].general.target_tags
  source_ranges = var.security_options.ssh_whitelist_ips
}

resource "google_compute_firewall" "firewall_rule_allow_ssh_iap" {
  for_each = local.roles
  name        = replace("${each.key}-${var.provider_name}-allow-ssh-iap", "_", "-")
  network     = google_compute_network.network.id
  description = "Allow SSH IAP 22 port for connecting via web interface"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = var.vm_config[each.key].general.target_tags
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "firewall_rule_allow_p2p" {
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name        = replace("${each.key}-${var.provider_name}-allow-p2p", "_", "-")
  network     = google_compute_network.network.id
  description = "Allow P2P ports"

  allow {
    protocol = "tcp"
    ports    = var.vm_config[each.key].general.ports.p2p
  }

  allow {
    protocol = "udp"
    ports    = var.vm_config[each.key].general.ports.p2p
  }

  target_tags   = var.vm_config[each.key].general.target_tags
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_rule_allow_rpc" {
  depends_on = [
    var.all_ips
  ]
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name        = replace("${each.key}-${var.provider_name}-allow-rpc", "_", "-")
  network     = google_compute_network.network.id
  description = "Allow RPC ports"

  allow {
    protocol = "tcp"
    ports    = var.vm_config[each.key].general.ports.rpc
  }

  target_tags   = var.vm_config[each.key].general.target_tags
  source_ranges = concat(
    var.security_options.rpc_ws_whitelist_ips,
    var.security_options.health_check_ips,
    each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
  )
}

resource "google_compute_firewall" "firewall_rule_allow_ws" {
  depends_on = [
    var.all_ips
  ]
  for_each = toset([
    for role in local.roles : role if role != "gbc_validator"
  ])
  name        = replace("${each.key}-${var.provider_name}-allow-ws", "_", "-")
  network     = google_compute_network.network.id
  description = "Allow WS ports"

  allow {
    protocol = "tcp"
    ports    = var.vm_config[each.key].general.ports.ws
  }

  target_tags   = var.vm_config[each.key].general.target_tags
  source_ranges = concat(
    var.security_options.rpc_ws_whitelist_ips,
    var.security_options.health_check_ips,
    each.key == "gc_node" ? var.all_ips["gbc_node"] : (each.key == "gbc_node" ? var.all_ips["gbc_validator"] : [])
  )
}
