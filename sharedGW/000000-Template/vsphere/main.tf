# Connection to vSphere provider
# Provider version should be specified --> versions.tf
# best practice
# https://github.com/hashicorp/terraform-provider-vsphere
# https://registry.terraform.io/providers/hashicorp/vsphere/latest

provider "vsphere" {
  vsphere_server = var.vsphere_server
  user           = var.vsphere_user
  password       = var.vsphere_password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}



# Access the existing Datacenter
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Access the Cluster and connect it to the Datacenter
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/compute_cluster

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Access the Datastore and connect it to the Datacenter
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Access the Network and connect it to the Datacenter
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Access the Virtual Machine templates
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine

data "vsphere_virtual_machine" "windows_template" {
  name          = "/${var.datacenter}/vm/TemplateVMs/${var.windows_template}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "linux_template" {
  name          = "/${var.datacenter}/vm/TemplateVMs/${var.linux_template}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create new VM folder per tenant
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/folder
resource "vsphere_folder" "folder" {
  path          = "shared Gateway/${var.tenant_name}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create the Virtual Machines (Windows/Linux)

resource "vsphere_virtual_machine" "windows_vm" {
  name             = "SrvTerraformDev001"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.windows_template.guest_id

  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.windows_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.windows_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.windows_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.windows_template.id
    linked_clone  = true

    # sysprep files possible
    customize {
      windows_options {
        computer_name  = "SrvTerraformDev001"
        workgroup      = "WORKGROUP"
        admin_password = "terraform"
      }

      network_interface {
        ipv4_address = ""
        ipv4_netmask = 24
      }

      ipv4_gateway    = ""
      dns_server_list = ["1.1.1.1", "1.0.0.1"]

      timeout = 15
    }
  }
}

resource "vsphere_virtual_machine" "linux_vm" {
  name             = "SrvTerraformDev002"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.linux_template.guest_id

  scsi_type = data.vsphere_virtual_machine.linux_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.linux_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.linux_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.linux_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.linux_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.linux_template.id
    linked_clone  = true

    customize {
      linux_options {
        host_name = "SrvTerraformDev002"
        domain    = "terraform.local"
      }

      network_interface {
        ipv4_address = ""
        ipv4_netmask = 24
      }

      ipv4_gateway    = ""
      dns_server_list = ["1.1.1.1", "1.0.0.1"]

      timeout = 15
    }
  }
}
