output "availability_domain" {
  description = "availability domain"
  value       = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "vcn_state" {
  description = "the state of the VCN"
  value       = oci_core_vcn.k8s_vcn.state
}

output "vcn_cidr" {
  description = "CIDR block of the core VCN"
  value       = oci_core_vcn.k8s_vcn.cidr_block
}

output "vcn_id" {
  description = "ID of the core VCN"
  value       = oci_core_vcn.k8s_vcn.id
}

output "subnet_state" {
  description = "The state of the subnet"
  value       = oci_core_subnet.k8s_subnet.state
}

output "subnet_id" {
  description = "ID of the core subnet"
  value       = oci_core_subnet.k8s_subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the core subnet"
  value       = oci_core_subnet.k8s_subnet.cidr_block
}

output "compute_instances_public_ip" {
  description = "Public IPs of created nodes"
  value       = [oci_core_instance.k8s_node[*].public_ip]
}

output "compute_instances" {
  description = "Names and IPs of created instances"
  value = {
    name       = oci_core_instance.k8s_node[*].display_name
    public_ip  = oci_core_instance.k8s_node[*].public_ip
    private_ip = oci_core_instance.k8s_node[*].private_ip
  }
}

output "lb_public_ip" {
  description = "Public IPs of LB"
  value       = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.ip_addresses[0].ip_address
}

output "lb_id" {
  description = "ID of LB"
  value       = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
}

output "oci_ubuntu_images" {
  description = "List of possible Ubuntu images"
  value = {
    display_name             = data.oci_core_images.oci_ubuntu_images.images[*].display_name
    operating_system         = data.oci_core_images.oci_ubuntu_images.images[*].operating_system
    operating_system_version = data.oci_core_images.oci_ubuntu_images.images[*].operating_system_version
    id                       = data.oci_core_images.oci_ubuntu_images.images[*].id
  }
}
