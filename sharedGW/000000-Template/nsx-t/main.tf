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



# Access the existing Transport Zone "nsx-dev-overlay-transportzone"
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/data-sources/policy_transport_zone

data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = "" # The Display Name prefix of the Transport Zone to retrieve.
}

# Access the existing T1 Gateway
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/data-sources/policy_tier1_gateway

data "nsxt_policy_tier1_gateway" "t1_gateway" {
  display_name = var.gateway_name
}


# Create a new Segment and assign it to previously accessed T1 Gateway including the Transport Zone
# https://registry.terraform.io/providers/vmware/nsxt/latest/docs/resources/policy_segment

resource "nsxt_policy_fixed_segment" "tenant_segment" {
  display_name        = var.segment_name # can also be declared here (required parameter)
  description         = ""
  connectivity_path   = data.nsxt_policy_tier1_gateway.t1_gateway.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr = var.gateway_address # can also be declared here (required parameter)
  }
}
