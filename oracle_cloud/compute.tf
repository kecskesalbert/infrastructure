# Value populated from *.tfvars.json
variable "compute" {
}

variable "ssh_public_key" {
  default = ""
}

# Availability domain
# Only certain availability domains are eligible for free tier 
data "oci_identity_availability_domain" "ad" {
	compartment_id = var.tenancy_ocid
	ad_number      = var.compute.ad_number
}

#output "inst_availability_domain" {
#	value = data.oci_identity_availability_domain.ad
#}

# OS images: https://docs.oracle.com/iaas/images/
# Only compatible images are returned
data "oci_core_images" "all_images" {
	compartment_id           = var.compute.compartment_ocid
	operating_system         = var.compute.os_name
	operating_system_version = var.compute.os_version
	shape                    = var.compute.shape
	sort_by                  = "TIMECREATED"
	sort_order               = "DESC"
}

#output "inst_image" {
#	value = data.oci_core_images.all_images.images[0].id
#}

# Shapes
# Unfortunately there is no attribute that tells if they're free tier eligible
data "oci_core_shapes" "all_shapes" {
    compartment_id = var.compute.compartment_ocid
    availability_domain = data.oci_identity_availability_domain.ad.name
    image_id = data.oci_core_images.all_images.images[0].id
}

#output "inst_shape" {
#	value = data.oci_core_shapes.all_shapes.shapes
#}

# TODO: get subnet id by name
#data "oci_core_subnet" "all_subnets" {
#  subnet_id = "123"
#}

# create a new TLS key
resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Display key content with: terraform output --raw ssh_private_key
# Create public key from private key: ssh-keygen -f private_key.pem -y
output "ssh_private_key" {
  value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
}

resource "oci_core_instance" "compute_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compute.compartment_ocid
  display_name        = var.compute.hostname
  shape               = var.compute.shape
  shape_config {
    ocpus = var.compute.cpu_count
    memory_in_gbs = var.compute.memory_gb
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.test_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = var.compute.hostname
  }

  source_details {
    source_type = "image"
#    source_id   = lookup(data.oci_core_images.all_images.images[0], "id")
	source_id = data.oci_core_images.all_images.images[0].id
  }

  metadata = {
    ssh_authorized_keys = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.public_key_openssh
  }
}

data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = var.compute.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.compute_instance.id
}

data "oci_core_vnic" "app_vnic" {
  vnic_id = data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0]["vnic_id"]
}

output "public_ip" {
  value = data.oci_core_vnic.app_vnic.public_ip_address
}
