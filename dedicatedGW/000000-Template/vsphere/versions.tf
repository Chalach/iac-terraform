terraform {
  required_providers {
    # Currently, this provider is not tested for vSphere 7, but plans are underway to add support.
    # MPL-2.0 License - https://github.com/hashicorp/terraform-provider-vsphere/blob/master/LICENSE
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "1.24.3"
    }
  }
}
