# Connection to NSX-T provider
# Provider version should be specified --> versions.tf
# best practice
# https://github.com/vmware/terraform-provider-nsxt
# https://registry.terraform.io/providers/vmware/nsxt/latest

provider "nsxt" {
  host                  = var.nsxt_server
  username              = var.nsxt_user
  password              = var.nsxt_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}



# Access the existing Edge Cluster "nsx-dev-t1-edge-clt01"
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/data-sources/policy_edge_cluster

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = "" # The Display Name prefix of the edge cluster to retrieve.
}

# Access the existing Transport Zone "nsx-dev-overlay-transportzone"
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/data-sources/policy_transport_zone

data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = "" # The Display Name prefix of the Transport Zone to retrieve.
}

# Access the existing T0 Gateway "DEV-T0-GW"
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/data-sources/policy_tier0_gateway

data "nsxt_policy_tier0_gateway" "t0_gateway" {
  display_name = "DEV-T0-GW" # The Display Name prefix of the Tier-0 gateway to retrieve.
}

# Create a new T1 Gateway
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/resources/policy_tier1_gateway

resource "nsxt_policy_tier1_gateway" "t1_gateway" {
  display_name              = var.gateway_name # can also be declared here (required parameter)
  description               = ""
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode             = "NON_PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0_gateway.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_IPSEC_LOCAL_ENDPOINT"]
  pool_allocation           = "ROUTING"
}


# Create a new Segment and assign it to the newly created T1 Gateway including the Transport Zone
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/resources/policy_segment

resource "nsxt_policy_fixed_segment" "tenant_segment" {
  display_name        = var.segment_name # can also be declared here (required parameter)
  description         = ""
  connectivity_path   = nsxt_policy_tier1_gateway.t1_gateway.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = var.gateway_address # can also be declared here (required parameter)
  }
}



# Define NAT Rules for the T1 Gateway
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/resources/policy_nat_rule

resource "nsxt_policy_nat_rule" "no_nat_class_A" {
  display_name         = "NO NAT Class A"
  action               = "NO_SNAT"
  source_networks      = [var.cidr] # can also be declared here (required parameter)
  destination_networks = ["10.0.0.0/8"]
  translated_networks  = [] # translated_network must be empty for Action NO_SNAT
  gateway_path         = nsxt_policy_tier1_gateway.t1_gateway.path
  logging              = false
  firewall_match       = "MATCH_INTERNAL_ADDRESS"
}

resource "nsxt_policy_nat_rule" "no_nat_class_B" {
  display_name         = "NO NAT Class B"
  action               = "NO_SNAT"
  source_networks      = [var.cidr] # can also be declared here (required parameter)
  destination_networks = ["172.16.0.0/12"]
  translated_networks  = [] # translated_network must be empty for Action NO_SNAT
  gateway_path         = nsxt_policy_tier1_gateway.t1_gateway.path
  logging              = false
  firewall_match       = "MATCH_INTERNAL_ADDRESS"
}

resource "nsxt_policy_nat_rule" "no_nat_class_C" {
  display_name         = "NO NAT Class C"
  action               = "NO_SNAT"
  source_networks      = [var.cidr] # can also be declared here (required parameter)
  destination_networks = ["192.168.0.0/16"]
  translated_networks  = [] # translated_network must be empty for Action NO_SNAT
  gateway_path         = nsxt_policy_tier1_gateway.t1_gateway.path
  logging              = false
  firewall_match       = "MATCH_INTERNAL_ADDRESS"
}

resource "nsxt_policy_nat_rule" "outbound_NAT_TenantT" {
  display_name         = "outbound NAT"
  action               = "SNAT"
  source_networks      = ["0.0.0.0/0"] # (OPTIONAL) If empty - Invalid CIDR in SOURCE_NETWORK of SNAT rule. (code 508024)
  destination_networks = []
  translated_networks  = [var.public_ip] # can also be declared here (required parameter)
  gateway_path         = nsxt_policy_tier1_gateway.t1_gateway.path
  logging              = false
  firewall_match       = "MATCH_INTERNAL_ADDRESS"
}
