resource "oci_core_instance" "k3d_vm" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "k3d-ha-cluster"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_subnet.id
    display_name     = "k3d-ha-cluster-vnic"
    assign_public_ip = true
    hostname_label   = "k3d-ha-cluster"
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-k3d.yaml", {
      username = var.vm_username
      ssh_public_key = local.ssh_public_key
      k3d_masters = var.k3d_masters
      k3d_workers = var.k3d_workers
    }))
  }

  freeform_tags = {
    "Project" = "k3d-code-server"
    "Type"    = "k3d-ha-cluster"
  }

  timeouts {
    create = "15m"
  }
}