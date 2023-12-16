resource "local_file" "ssh" {
  count = var.create_ansible_inventory_vars ? var.instance_count : 0
  content = templatefile("${path.module}/ssh.tmpl",
    {
      host_name = oci_core_instance.k8s_node[count.index].display_name
      public_ip = oci_core_instance.k8s_node[count.index].public_ip
    }
  )
  filename = "ssh_${oci_core_instance.k8s_node[count.index].display_name}.sh"
}