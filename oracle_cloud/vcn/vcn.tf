resource "oci_core_vcn" "vcn" {
	display_name   = var.vcn_values.name
	dns_label      = var.vcn_values.name
	compartment_id = var.vcn_values.compartment_ocid
	cidr_block     = var.vcn_values.cidr
}

resource "oci_core_internet_gateway" "internet_gateway" {
	for_each = var.vcn_values.internet_gateways
	vcn_id         	= oci_core_vcn.vcn.id
	compartment_id 	= try(each.value.compartment_ocid, var.vcn_values.compartment_ocid)
	display_name   	= each.key
	enabled			= try(each.value.enabled, true)
}

resource "oci_core_route_table" "route_table" {
	for_each = var.vcn_values.route_tables
	vcn_id         = oci_core_vcn.vcn.id
	compartment_id = try(each.value.compartment_ocid, var.vcn_values.compartment_ocid)
	display_name   = each.key

	dynamic "route_rules" {
		for_each = each.value.rules
		content {
			description = try(route_rules.value.description, null)
			destination = route_rules.value.destination
			destination_type = try(route_rules.value.destination_type, "CIDR_BLOCK")
			network_entity_id =	route_rules.value.network_entity[0] == "ig" ? oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity[1]].id : "N/A"
		}
	}
}

resource "oci_core_dhcp_options" "dhcp_options" {
	for_each = var.vcn_values.dhcp_options
	vcn_id         = oci_core_vcn.vcn.id
	compartment_id = try(each.value.compartment_ocid, var.vcn_values.compartment_ocid)
	display_name   = each.key
	dynamic "options" {
		for_each = each.value.options
		content {
			type = options.value.type
			custom_dns_servers = try(options.value.custom_dns_servers, null)
			search_domain_names = try(options.value.search_domain_names, null)
			server_type = try(options.value.server_type, null)
		}
	}
}

resource "oci_core_security_list" "security_lists" {
	for_each = var.vcn_values.security_lists
	vcn_id         = oci_core_vcn.vcn.id
	compartment_id = try(each.value.compartment_ocid, var.vcn_values.compartment_ocid)
	display_name   = each.key

	dynamic "egress_security_rules" {
		for_each = try(each.value.egress_security_rules, {})
		content {
			destination	= egress_security_rules.value.destination
			protocol = contains(keys(egress_security_rules.value), "tcp_port") ? 6 : (
				contains(keys(egress_security_rules.value), "udp_port") ? 17 : (
				contains(keys(egress_security_rules.value), "icmp") ? 1 : -1 )
			)
			stateless = try(egress_security_rules.stateless, null)
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
		for_each = try(each.value.ingress_security_rules, {})
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

resource "oci_core_subnet" "subnets" {
	for_each = var.vcn_values.subnets
	vcn_id            = oci_core_vcn.vcn.id
	compartment_id = try(each.value.compartment_ocid, var.vcn_values.compartment_ocid)
	cidr_block        = each.value.cidr_block
	display_name      = each.key
	dns_label         = each.key
	security_list_ids = contains(keys(each.value), "security_lists") ? [
		for name in each.value.security_lists : (
			name == "default" ?
				oci_core_vcn.vcn.default_security_list_id :
				oci_core_security_list.security_lists[name].id
			)
	] : [ oci_core_vcn.vcn.default_security_list_id ]
    route_table_id    = try(
            oci_core_route_table.route_table[each.value.route_table].id,
            oci_core_vcn.vcn.default_route_table_id
    )
    dhcp_options_id   = try(
            oci_core_dhcp_options.dhcp_options[each.value.dhcp_options].id,
            oci_core_vcn.vcn.default_dhcp_options_id
    )
}