
# Value populated from *.tfvars.json
variable "vcn" {
}

# Protocol numbers: TCP=6, UDP=17, ICMP=1, ICMPv6=58
# https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

resource "oci_core_virtual_network" "test_vcn" {
	compartment_id = var.vcn.compartment_ocid
	cidr_block     = var.vcn.cidr
	display_name   = var.vcn.name
	dns_label      = var.vcn.name
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
	compartment_id = var.vcn.compartment_ocid
	display_name   = "testIG"
	vcn_id         = oci_core_virtual_network.test_vcn.id
}

resource "oci_core_route_table" "test_route_table" {
	compartment_id = var.vcn.compartment_ocid
	vcn_id         = oci_core_virtual_network.test_vcn.id
	display_name   = "testRouteTable"

	route_rules {
		destination       = "0.0.0.0/0"
		destination_type  = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
	}
}

# Port number=-1 is used for any port
resource "oci_core_security_list" "test_security_list" {
	compartment_id = var.vcn.compartment_ocid
	vcn_id         = oci_core_virtual_network.test_vcn.id
	display_name   = "testSecurityList"

	dynamic "egress_security_rules" {
		for_each = var.vcn.egress_security_rules
		content {
			destination	= egress_security_rules.value.destination
			protocol = contains(keys(egress_security_rules.value), "tcp_port") ? 6 : (
				contains(keys(egress_security_rules.value), "udp_port") ? 17 : (
				contains(keys(egress_security_rules.value), "icmp") ? 1 : -1 )
			)
			dynamic "tcp_options" {
				for_each = (!contains(keys(egress_security_rules.value), "tcp_port") ||
							try(egress_security_rules.value.tcp_port, -1) == -1
							) ? [] : [ egress_security_rules.value.tcp_port ]
				content {
					max = egress_security_rules.value.tcp_port
					min = egress_security_rules.value.tcp_port
				}
			}
			dynamic "udp_options" {
				for_each = (!contains(keys(egress_security_rules.value), "udp_port") ||
							try(egress_security_rules.value.udp_port, -1) == -1
							) ? [] : [ egress_security_rules.value.udp_port ]
				content {
					max = egress_security_rules.value.udp_port
					min = egress_security_rules.value.udp_port
				}
			}
		}
	}

	dynamic "ingress_security_rules" {
		for_each = var.vcn.ingress_security_rules
		content {
			source	= ingress_security_rules.value.source
			protocol = contains(keys(ingress_security_rules.value), "tcp_port") ? 6 : (
				contains(keys(ingress_security_rules.value), "udp_port") ? 17 : (
				contains(keys(ingress_security_rules.value), "icmp") ? 1 : -1 )
			)

			dynamic "tcp_options" {
				for_each = (!contains(keys(ingress_security_rules.value), "tcp_port") ||
							try(ingress_security_rules.value.tcp_port, -1) == -1
							) ? [] : [ ingress_security_rules.value.tcp_port ]
				content {
					max = ingress_security_rules.value.tcp_port
					min = ingress_security_rules.value.tcp_port
				}
			}

			dynamic "udp_options" {
				for_each = (!contains(keys(ingress_security_rules.value), "udp_port") ||
							try(ingress_security_rules.value.udp_port, -1) == -1
							) ? [] : [ ingress_security_rules.value.udp_port ]
				content {
					max = ingress_security_rules.value.udp_port
					min = ingress_security_rules.value.udp_port
				}
			}
		}
	}

}

# Security lists apply to subnets
# Default security list applies when not provided
resource "oci_core_subnet" "test_subnet" {
	compartment_id    = var.vcn.compartment_ocid
	cidr_block        = "10.1.20.0/24"
	display_name      = "testSubnet"
	dns_label         = "testsubnet"
	# security_list_ids = [oci_core_security_list.test_security_list.id]
	vcn_id            = oci_core_virtual_network.test_vcn.id
	route_table_id    = oci_core_route_table.test_route_table.id
	dhcp_options_id   = oci_core_virtual_network.test_vcn.default_dhcp_options_id
}
