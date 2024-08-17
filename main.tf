################################################################################
# Compute instances
################################################################################

locals {
  # number_of_availability_domains = length(data.oci_identity_availability_domains.ads.availability_domains)
  instance_image    = data.oci_core_images.oci_ubuntu_images.images[0].id
  instance_firmware = data.oci_core_images.oci_ubuntu_images.images[0].launch_options[0].firmware
}

resource "oci_core_instance" "k8s_node" {
  count = var.instance_count

  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute RDMA GPU Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Auto-Configuration"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Authentication"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  # availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % local.number_of_availability_domains].name
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domains[count.index]].name
  compartment_id      = var.compartment_id
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = true
    assign_public_ip          = true
    subnet_id                 = oci_core_subnet.k8s_subnet.id
  }
  display_name = "k8s_node${count.index}"
  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }
  metadata = {
    # ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
    ssh_authorized_keys = var.id_rsa_pub
  }
  preserve_boot_volume = false
  shape                = var.instance_shape
  shape_config {
    baseline_ocpu_utilization = "BASELINE_1_1"
    memory_in_gbs             = 1
    ocpus                     = 1
  }
  source_details {
    source_id   = local.instance_image
    source_type = "image"
  }

  # lifecycle {
  #   precondition {
  #     condition     = local.instance_firmware == "UEFI_64"
  #     error_message = "Use firmware compatible with 64 bit operating systems"
  #   }
  # }
}

data "oci_core_images" "oci_ubuntu_images" {
  compartment_id = var.compartment_id
  sort_by        = "TIMECREATED"
  sort_order     = "DESC"

  filter {
    name   = "operating_system"
    values = ["Canonical Ubuntu"]
  }

  filter {
    name   = "operating_system_version"
    values = ["22.04 Minimal"]
  }

  # filter {
  #   name   = "display_name"
  #   values = [".*aarch64.*"]
  #   regex  = true
  # }

}

################################################################################
# Network
################################################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_vcn" "k8s_vcn" {
  dns_label      = "k8svcn"
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = "K8s VCN"
}

resource "oci_core_internet_gateway" "k8s_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k8s_vcn.id
  enabled        = true
  display_name   = "K8s Inet Gateway"
}

# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformbestpractices_topic-vcndefaults.htm
resource "oci_core_default_route_table" "k8s_vcn_route_table" {
  manage_default_resource_id = oci_core_vcn.k8s_vcn.default_route_table_id
  compartment_id             = var.compartment_id
  display_name               = "K8s default route table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.k8s_internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "k8s_subnet" {
  cidr_block     = var.subnet_cidr_block
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k8s_vcn.id
  display_name   = "K8s subnet"
  dns_label      = "k8ssubnet"
}

################################################################################
# Load balancer
################################################################################

resource "oci_network_load_balancer_backend" "k8s_backend" {
  count                    = var.instance_count
  backend_set_name         = oci_network_load_balancer_backend_set.k8s_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  port                     = 16443
  ip_address               = oci_core_instance.k8s_node[count.index].private_ip
  name                     = "k8s_backend_${oci_core_instance.k8s_node[count.index].display_name}"
}

resource "oci_network_load_balancer_backend_set" "k8s_backend_set" {
  health_checker {
    protocol           = "HTTPS"
    interval_in_millis = 10000
    port               = 16443
    retries            = 3
    return_code        = 401
    timeout_in_millis  = 3000
    url_path           = "/"
  }
  name                     = "K8s bucket set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_listener" "k8s_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.k8s_backend_set.name
  name                     = "K8s API listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  port                     = 16443
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend" "nginx_http_backend" {
  count                    = var.instance_count
  backend_set_name         = oci_network_load_balancer_backend_set.nginx_http_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  port                     = 80
  ip_address               = oci_core_instance.k8s_node[count.index].private_ip
  name                     = "nginx_http_backend${oci_core_instance.k8s_node[count.index].display_name}"
}

resource "oci_network_load_balancer_backend_set" "nginx_http_backend_set" {
  health_checker {
    protocol           = "HTTP"
    interval_in_millis = 10000
    port               = 80
    retries            = 3
    return_code        = 200
    timeout_in_millis  = 3000
    url_path           = "/"
  }
  name                     = "NGINX HTTP bucket set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_listener" "nginx_http_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nginx_http_backend_set.name
  name                     = "NGINX HTTP listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer.id
  port                     = 80
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_network_load_balancer" "k8s_network_load_balancer" {
  compartment_id = var.compartment_id
  display_name   = "K8s network load balancer"
  subnet_id      = oci_core_subnet.k8s_subnet.id
  is_private     = false
}

################################################################################
# Security
################################################################################

resource "oci_core_default_security_list" "k8s_vcn_security_list" {
  manage_default_resource_id = oci_core_vcn.k8s_vcn.default_security_list_id
  compartment_id             = var.compartment_id
  display_name               = "K8s security list"
  dynamic "egress_security_rules" {
    for_each = var.egress_security_rules
    iterator = security_rule
    content {
      protocol         = security_rule.value["protocol"]
      destination      = security_rule.value["destination"]
      destination_type = security_rule.value["destination_type"]
      description      = security_rule.value["description"]
    }
  }
  dynamic "ingress_security_rules" {
    for_each = {
      for k, v in var.ingress_security_rules : k => v if v["protocol"] == "6"
    }
    iterator = security_rule
    content {
      protocol    = security_rule.value["protocol"]
      source      = security_rule.value["source"]
      source_type = security_rule.value["source_type"]
      description = security_rule.value["description"]
      tcp_options {
        max = security_rule.value["port"]
        min = security_rule.value["port"]
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = {
      for k, v in var.ingress_security_rules : k => v if v["protocol"] == "1"
    }
    iterator = security_rule
    content {
      protocol    = security_rule.value["protocol"]
      source      = security_rule.value["source"]
      source_type = security_rule.value["source_type"]
      description = security_rule.value["description"]
    }
  }
  ingress_security_rules {
    protocol    = "all"
    source      = var.my_public_ip
    source_type = "CIDR_BLOCK"
    description = "Allow my public IP for all protocols"
  }
  ingress_security_rules {
    protocol    = 1
    source      = oci_core_subnet.k8s_subnet.cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow subnet for ICMP"
    icmp_options {
      type = 3
    }
  }
  ingress_security_rules {
    protocol    = "all"
    source      = oci_core_subnet.k8s_subnet.cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow subnet for all protocols"
  }
}
