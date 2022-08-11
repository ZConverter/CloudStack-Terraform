resource "cloudstack_ssh_keypair" "keypair" {
  name       = "${var.generate.vm_info.vm_name}-key"
  project    = var.generate.vm_info.project
}

resource "cloudstack_instance" "web" {
  name                 = var.generate.vm_info.vm_name
  project              = var.generate.vm_info.project
  affinity_group_names = var.generate.vm_info.affinity_group_names
  service_offering     = var.generate.vm_info.service_offering
  root_disk_size       = var.generate.vm_info.root_disk_size
  network_id           = var.generate.vm_info.network_id
  security_group_names = var.generate.vm_info.security_group_names
  template             = var.generate.vm_info.template
  zone                 = var.generate.vm_info.zone
  keypair          = cloudstack_ssh_keypair.keypair.name
}
