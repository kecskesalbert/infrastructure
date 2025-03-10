variable "vcn_name" {
	description = "VCN name"
	type = string
	default = "entcorpnetwork"
}

variable "vcn_dns_name" {
	description = "VCN DNS label/name"
	type = string
	default = "entcorpnetwork"
}

variable "vcn_compartment_ocid" {
	type = string
	description = "Compartment OCID"
}

variable "vcn_cidr" {
	description = "VCN CIDR"
	type = string
	default = "10.0.0.0/16"
}

variable "vcn_internet_gateways" {
	description = ""
	type = map
	default = {
		"default": {}
	}
}

variable "vcn_route_tables" {
	description = ""
	type = map
#	default = {}
}

variable "vcn_dhcp_options" {
	description = ""
	type = map
#	default = {}
}

variable "vcn_security_lists" {
	description = ""
	type = map(object({
		ingress_security_rules = list(map(string))
		egress_security_rules = list(map(string))
	}))
}

variable "vcn_subnets" {
	description = ""
	type = map(object({
		name = string
		cidr_block = string
		security_lists = list(string)
		route_table = string
		dhcp_options = string
	}))
}