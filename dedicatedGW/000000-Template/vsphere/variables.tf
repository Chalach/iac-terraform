# Reference
# https://www.terraform.io/docs/language/values/variables.html

# Login variables
variable "vsphere_server" {
  description = "vSphere server"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

# Datacenter values
variable "datacenter" {
  description = "vSphere data center"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore"
  type        = string
}

variable "network_name" {
  description = "vSphere network name"
  type        = string
}

variable "windows_template" {
  description = "Name of the Windows template"
  type        = string
}

variable "linux_template" {
  description = "Name of the Linux template"
  type        = string
}

variable "tenant_name" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
  type        = string
}