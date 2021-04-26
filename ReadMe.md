# Terraform Code Templates
This code repository includes two major examples:

* Dedicated T1-Gateway created by Terraform
* Shared T1-Gateway created by Terraform

The first code template creates a tenant with a dedicated T1-Gateway and the second code template adds a tenant to an already existing T1-Gateway. There is a terraform.tfvars file in the respective directories which must be adapted according to the customer requirements.

## Import existing resource
There is also the support document "import_helper.txt" included if a shared firewall rule needs to be imported and customized (e.g.: Internet access).