
# Oracle Cloud Infrastrucure

Provision infrastructure resources in Oracle Cloud
Work in progress

## Pre-requisites
Set up environment variables for:
- user_ocid
- private_key_path
- fingerprint
> See https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm#environment-variables for details.

## compute.tf
	Provision a compute instance
	
###	Input variables:
	compartment_ocid:	Compartment OCID
	ad_number:			Availability domain number
		Only certain availability domains are eligible for free tier.
	shape:				Instance shape
	    List of possible shapes: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
	os_name: 			Operating system name
	os_version: 		Operating system version
		List of possible OS images: https://docs.oracle.com/iaas/images/
	cpu_count: 			CPU core count
	memory_gb: 			Memory size in GB
	hostname: 			Hostname and DNS name
	subnet_name: 		Name of subnet for the VNIC to connect to
	Subnet names are not unique.
		Script stops with error when more than 1 subnet matches with the given name.
	have_ssh_key: 		SSH public key filename (optional)
		Filename containing a SSH public key in OpenSSH PEM (RFC 4716) format.
		If not defined, a random key will be generated and printed.

###	Output variables:
	public_ip:			The public IP of the network card
	ssh_private_key:	SSH key private part
		Display sensitive content with: terraform output --raw ssh_private_key
	ssh_public_key:		SSH key public part

## vcn module
	Provision a VCN with security lists, internet gateway, route table, dhcp options and subnets

###	Input variables:
	vcn_name:			VCN name
	vcn_values:			Object containing the VCN attributes
	    compartment_ocid:	Compartment OCID
	    cidr:				VCN CIDR
	    security_lists:     Object containing the security lists
	        compartment_ocid:  Optional, defaults to vcn_values.compartment_ocid if not defined
	        ingress_security_rules:	Array of inbound rules
    			source:     Source subnet CIDR
	    		tcp_port:   Optional, TCP port number or -1 for any TCP port
		    	udp_port:   Optional, UDP port number or -1 for any UDP port
		    	*Note: Either tcp_port or udp_port must be defined.*
	        egress_security_rules: Array of outbound rules
			    destination: Destination subnet CIDR
	    		tcp_port:   Optional, TCP port number or -1 for any TCP port
		    	udp_port:   Optional, UDP port number or -1 for any UDP port
		    	*Note: Either tcp_port or udp_port must be defined.*
        internet_gateways:  Object containing Internet Gateway definitions
			Key value will be used for the OCI object display name
	        compartment_ocid:  Optional, defaults to vcn_values.compartment_ocid if not defined
            enabled:    Optional, Gateway can be enabled/disabled
        route_tables:	Object containing routing table definitions
			Key value will be used for the OCI object display name
			compartment_ocid:  Optional, defaults to vcn_values.compartment_ocid if not defined
	        rules: Array with the routing table rows
		        destination: Destination subnet CIDR
		        network_entity: Array of [ gateway_type, gateway_name ]
			        gateway_type: Route rule target gateway type. Possible values:
				        ig:	Internet Gateway
				        drg: Dynamic Routing Gateway (Not yet implemented)
						natg: NAT gateway (Not yet implemented)
						servg: Service gateway (Not yet implemented)
						lpg: Local peering gateway (Not yet implemented)
						pip: Private IP (Not yet implemented)
					gateway_name: Route rule target gateway name
		dhcp_options:	Object containing DHCP options definitions
			Key value will be used for the OCI object display name
	        compartment_ocid:  Optional, defaults to vcn_values.compartment_ocid if not defined
		    options: Array of dhcp options rows
				type:	Dhcp option type
				custom_dns_servers:	Optional
				search_domain_names:	Optional
				server_type:	Optional

###	Output variables: