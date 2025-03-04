
# Protocol numbers: TCP=6, UDP=17, ICMP=1, ICMPv6=58
# https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# Port number=-1 is used for any port

# Note: A default security list is created with each VCN,  named "Default Security List for ${vcn_name}". This can't be referenced/assigned, since TF doesn't know about it.

# TODO: NSGs
# TODO: Add Oracle's stock ICMP rules to "default" security list
# TODO: Add a security list to allow incoming ping
# TODO: Gateway definition and Routing table support for Dynamic Routing Gateway (DRG)
# TODO: Gateway definition and Routing table support for NAT gateway (NATG)
# TODO: Gateway definition and Routing table support for Service gateway (SG)
# TODO: Gateway definition and Routing table support for Local peering gateway (LPG)
# TODO: Routing table support for Private IP

variable "vcn" {
}

module "vcn" {
	for_each = var.vcn
	source = "./vcn"
	vcn_name = each.key
	vcn_values = each.value
}