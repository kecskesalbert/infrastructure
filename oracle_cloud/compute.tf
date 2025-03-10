# TODO: Move to a module
# TODO: VNIC NSGs
# TODO: Allow referencing non TF-managed resources
# TODO: Run post-create actions

# Value populated from *.tfvars.json
variable "compute" {
}

data "oci_identity_availability_domain" "ad" {
	compartment_id = var.tenancy_ocid
	ad_number      = var.compute.ad_number
}

#output "inst_availability_domain" {
#	value = data.oci_identity_availability_domain.ad
#}

data "oci_core_images" "all_images" {
	compartment_id           = var.compute.compartment_ocid
	operating_system         = var.compute.os_name
	operating_system_version = var.compute.os_version
	shape                    = var.compute.shape
	sort_by                  = "TIMECREATED"
	sort_order               = "DESC"
}

#output "all_images" {
#	value = data.oci_core_images.all_images.images
#}

locals {
	os_image_id = coalescelist(data.oci_core_images.all_images.images, [{id="dummy"}])[0].id
}

#output "os_image_id" {
#	value = local.os_image_id
#}

# Shapes
# Unfortunately there is no attribute that tells if they're free tier eligible
data "oci_core_shapes" "all_shapes" {
    compartment_id = var.compute.compartment_ocid
    availability_domain = data.oci_identity_availability_domain.ad.name
    image_id = local.os_image_id
}

#output "inst_shapes" {
#	value = data.oci_core_shapes.all_shapes.shapes
#}

# create a new TLS key
resource "tls_private_key" "compute_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}

locals {
	ssh_public_key = ( (try(var.compute.have_ssh_key, "") != "") ?
		file(var.compute.have_ssh_key) :
		tls_private_key.compute_ssh_key.public_key_openssh
	)
	matching_subnets = [
		for s in module.entcorp_vcn.subnets :
			s if s.display_name == var.compute.subnet_name
	]
}

output "ssh_private_key" {
	value     = (try(var.compute.have_ssh_key, "") == "") ? tls_private_key.compute_ssh_key.private_key_pem : "(external)"
	sensitive = true
}

output "ssh_public_key" {
	value     = local.ssh_public_key
}

resource "oci_core_instance" "compute_instance" {

	# Validate the supplied parameters to avoid the unspecific "create failed" error
	lifecycle {
		precondition {
			condition     = local.os_image_id != "dummy"
			error_message = "Error: OS image not found for: ${var.compute.os_name}, ${var.compute.os_version}, ${var.compute.shape}"
		}
		precondition {
			condition     = contains(coalescelist(data.oci_core_shapes.all_shapes.shapes, [{name="dummy"}]).*.name, var.compute.shape)
			error_message = "Error: Shape not found: ${var.compute.shape}"
		}
		precondition {
			condition     = length(local.matching_subnets) == 1
			error_message = "Error: Subnet name is ambiguous: ${var.compute.subnet_name}"
		}
	}

	availability_domain = data.oci_identity_availability_domain.ad.name
	compartment_id      = var.compute.compartment_ocid
	display_name        = var.compute.hostname
	shape               = var.compute.shape
	shape_config {
		ocpus 			= var.compute.cpu_count
		memory_in_gbs 	= var.compute.memory_gb
	}

	create_vnic_details {
		subnet_id 		 = local.matching_subnets[0].id
		display_name     = "primaryvnic"
		assign_public_ip = true
		hostname_label   = var.compute.hostname
	}

	source_details {
		source_type = "image"
		source_id = local.os_image_id
	}

	metadata = {
		ssh_authorized_keys = local.ssh_public_key
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