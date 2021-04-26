# Reference
# https://www.terraform.io/docs/language/values/variables.html

# Login variables
variable "nsxt_user" {
  description = "NSX-T Username"
  type        = string
}

variable "nsxt_password" {
  description = "NSX-T Password"
  type        = string # Type safety
  sensitive   = true   # Limits Terraform UI output when the variable is used in configuration. 
}

variable "nsxt_server" {
  description = "NSX-T Server"
  type        = string
}

# Gateway
variable "gateway_name" {
  description = "T-1 Gateway Name"
  type        = string
}

variable "segment_name" {
  description = "Segment Name"
  type        = string
}

variable "gateway_address" {
  description = "Gateway IP Address"
  type        = string
}
