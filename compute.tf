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
