
Provision resources in Oracle Cloud
Work in progress

Setup
	Set up environment variables for user_ocid, private_key_path and fingerprint
	See https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm#environment-variables for details.


compute.tf
	Provision a compute instance
	
	Input variables:
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
		subnet_name: 		Name of subnet to connect to
			Subnet names are not unique. Script stops with error when more than 1 subnet matches with the given name.
		have_ssh_key: 		SSH public key filename
			This parameter is optional. When defined, it must point to filename containing a SSH public key in OpenSSH PEM (RFC 4716) format. If not defined, a random key will be generated and printed.
			
	Output variables:
		public_ip:			The public IP of the network card
		ssh_private_key:	SSH key private part
			Display sensitive content with: terraform output --raw ssh_private_key
		ssh_public_key:		SSH key public part

network.tf
	Provision a VCN with subnets, security lists, gateways

	Input variables:
		compartment_ocid:	Compartment OCID
		name:				VCN name 
		cidr				VCN CIDR
		ingress_security_rules:	List of inbound rules
			An ingress rule can have these attributes:
				source (mandantory)
				tcp_port (optional)
				udp_port (optional)
			Either tcp_port or udp_port must be defined. -1 means any port.
		egress_security_rules: List of outbound rules
			An egress rule can have these attributes:
				destination (mandantory)
				tcp_port (optional)
				udp_port (optional)
			Either tcp_port or udp_port must be defined. -1 means any port.		

	Output variables: