output "vcn" {
  description = "VCN created"
  value       = oci_core_vcn.vcn
}

output "subnets" {
  description = "Subnets created"
  value       = oci_core_subnet.subnets
}
