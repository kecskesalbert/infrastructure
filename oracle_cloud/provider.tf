terraform {
    required_providers { 
        oci = { 
            source = "hashicorp/oci" 
            version = ">= 6.27.0" 
        } 
    }
	required_version = ">= 1.10.0"
}

# Value populated from *.tfvars.json
variable "tenancy_ocid" {
}

# Value populated from *.tfvars.json
variable "region" {
}

# user_ocid, private_key_path and fingerprint values are taken from environment variables
#  https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm#environment-variables
provider "oci" {
	tenancy_ocid     = var.tenancy_ocid
	region           = var.region
}

# OCI provider refernce:
# https://registry.terraform.io/providers/oracle/oci/latest/docs