module "entcorp_vcn" {
	source = "./vcn"
	vcn_name 				= "icecream-network"
	vcn_dns_name 			= "icenet"
	vcn_compartment_ocid 	=  "ocid1.compartment.oc1..aaaaaaaaux4kvq5yjlwwtiortyoyq7tiqcmrb5sqej4gy2s525ybxptew7pa"
	vcn_cidr 				= "10.1.0.0/16"
	vcn_internet_gateways 	= {
		"default": {}
	}
	vcn_route_tables 		= {
		"testRouteTable": {
			"rules": [
				{
					"destination": "0.0.0.0/0",
					"network_entity": [ "ig", "default" ]
				}
			]
		}
	}
	vcn_dhcp_options 		= {
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
	}
	vcn_security_lists 		= {
		"http_in": {
			"ingress_security_rules": [
				{
					"source": "0.0.0.0/0",
					"udp_port": 80
				}
			],
			egress_security_rules: null
		},
		"rdp_in": {
			"ingress_security_rules": [
				{
					"source": "0.0.0.0/0",
					"udp_port": 3389
				}
			],
			egress_security_rules: null
		}
	}
	vcn_subnets = {
		"subnet1": {
			"name": "frontend",
			"cidr_block": "10.1.20.0/24",
			"security_lists": [ "default", "http_in" ],
			"route_table": "testRouteTable",
			"dhcp_options": null
		},
		"subnet2": {
			"name": "backend",
			"cidr_block": "10.1.21.0/24",
			"security_lists": [ "default" ],
			"route_table": "testRouteTable",
			"dhcp_options": "dhcpoption1"
		}
	}
}
