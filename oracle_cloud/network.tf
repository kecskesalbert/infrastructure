# TODO: Add NSGs
# TODO: Add a security list to allow incoming ping
# TODO: document magic "default" security list

# TODO: Gateway definition and routing table support for Dynamic Routing Gateway
# TODO: Gateway definition and routing table support for NAT gateway
# TODO: Gateway definition and routing table support for Service gateway
# TODO: Gateway definition and routing table support for Local peering gateway
# TODO: Routing table support for Private IP

variable "vcn" {
}

locals {
	entcorpnetwork = {
		"name": "entnetwork",
		"compartment_ocid":  "ocid1.compartment.oc1..aaaaaaaaux4kvq5yjlwwtiortyoyq7tiqcmrb5sqej4gy2s525ybxptew7pa",
		"cidr": "10.1.0.0/16",
		"security_lists": {
			"allowout": {
				"ingress_security_rules": [
					{
						"source": "0.0.0.0/0",
						"tcp_port": 22
					}
				],
				"egress_security_rules": [
					{
						"destination": "0.0.0.0/0",
						"tcp_port": -1
					}
				]
			},
			"http_in": {
				"ingress_security_rules": [
					{
						"source": "0.0.0.0/0",
						"udp_port": 80
					}
				]
			},
			"rdp_in": {
				"ingress_security_rules": [
					{
						"source": "0.0.0.0/0",
						"udp_port": 3389
					}
				]
			}
		},
		"internet_gateways": {
			"default": {}
		},
		"route_tables": {
			"testRouteTable": {
				"rules": [
					{
						"destination": "0.0.0.0/0",
						"network_entity": [ "ig", "default" ]
					}
				]
			}
		},
		"dhcp_options": {
			"dhcpoption1": {
				"options": [
					{
						"type": "DomainNameServer",
						"custom_dns_servers": [ "1.1.1.1", "1.0.0.1" ],
						"server_type": "CustomDnsServer"
					},
					{
						"type": "SearchDomain",
						"search_domain_names": [ "mysearchdomain" ]
					}
				]
			}
		},
		"subnets": {
			"testSubnet": {
				"cidr_block": "10.1.20.0/24",
				"security_lists": [ "default", "http_in" ],
				"route_table": "testRouteTable",
				"dhcp_options": "dhcpoption1"
			}
		}
	}
		
}
		

module "vcn" {
	source = "./vcn"
	for_each = var.vcn
	vcn_values = each.value
}