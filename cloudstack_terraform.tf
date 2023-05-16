resource "cloudstack_ssh_keypair" "keypair" {
  name    = "${var.generate.vm_info.vm_name}-key"
  project = var.generate.vm_info.project
}

resource "cloudstack_security_group" "create_security_group" {
  name        = "${var.generate.vm_info.vm_name}-sg"
  description = "${var.generate.vm_info.vm_name}-security-group"
}

resource "cloudstack_security_group_rule" "create_security_group_rule" {
  security_group_id = cloudstack_security_group.create_security_group.id

  dynamic "rule" {
    for_each = var.generate.vm_info.create_security_group.ingress != null ? var.generate.vm_info.create_security_group.ingress : []
    iterator = ingress
    content {
      traffic_type = "ingress"
      cidr_list = formatlist(ingress.value["cidr"])
      protocol = ingress.value["protocol"]
      ports = ingress.value["port"] != null ? formatlist(ingress.value["port"]) : null
    }
  }

  dynamic "rule" {
    for_each = var.generate.vm_info.create_security_group.egress != null ? var.generate.vm_info.create_security_group.egress : []
    iterator = egress
    content {
      traffic_type = "egress"
      cidr_list = formatlist(egress.value["cidr"])
      protocol = egress.value["protocol"]
      ports = egress.value["port"] != null ? formatlist(egress.value["port"]) : null
    }
  }
}

resource "cloudstack_static_nat" "static_nat" {
  count = var.generate.vm_info.ip_address != null ? 1 : 0
  ip_address_id      = var.generate.vm_info.ip_address
  virtual_machine_id = cloudstack_instance.create_openstack_instance.id
}

resource "cloudstack_firewall" "default" {
count = var.generate.vm_info.ip_address != null ? 1 : 0
  ip_address_id = var.generate.vm_info.ip_address
  rule {
    cidr_list = ["0.0.0.0/0"]
    protocol  = "tcp"
    ports     = ["1-65535"]
  }
}

resource "cloudstack_instance" "create_openstack_instance" {
  name                 = var.generate.vm_info.vm_name
  project              = var.generate.vm_info.project
  affinity_group_names = var.generate.vm_info.affinity_group_names
  service_offering     = var.generate.vm_info.service_offering
  root_disk_size       = var.generate.vm_info.root_disk_size
  network_id           = var.generate.vm_info.network_id
  security_group_names = concat(var.generate.vm_info.security_group_names,formatlist(cloudstack_security_group.create_security_group.name))
  template             = var.generate.vm_info.template
  zone                 = var.generate.vm_info.zone
  keypair              = cloudstack_ssh_keypair.keypair.name
  expunge              = true
  user_data = var.generate.vm_info.vm_name == "zdm" ? var.generate.vm_info.ip_address != null ? templatefile(
    "./tftpl/zdm.tftpl",
    {
      zdmip = cloudstack_static_nat.static_nat[0].vm_guest_ip
    }
  ) : null : var.generate.vm_info.user_data_file_path != null ? base64encode(file(var.generate.vm_info.user_data_file_path)) : null
}

resource "cloudstack_disk" "create_disk" {
  count = length(var.generate.vm_info.volume)
  name               = "${var.generate.vm_info.vm_name}-disk${count.index}"
  attach             = true
  disk_offering      = "custom"
  size               = var.generate.vm_info.volume[count.index]
  virtual_machine_id = cloudstack_instance.create_openstack_instance.id
  zone               = var.generate.vm_info.zone
}

locals {
  security_group_information = {
    security_group = cloudstack_security_group.create_security_group,
    security_group_rules = [
      for rule_data in cloudstack_security_group_rule.create_security_group_rule :
      rule_data
    ]
  }
  volume_information = [
    for volume_data in cloudstack_disk.create_disk :
    volume_data
  ]
  result = {
    instance_information = cloudstack_instance.create_openstack_instance,
    keypair_information = cloudstack_ssh_keypair.keypair,
    security_group_information = local.security_group_information
    volume_information = local.volume_information
  }
}

resource "local_file" "output_private_key" {
  filename = "${path.cwd}/${var.generate.vm_info.vm_name}_private_key.pem"

  content = cloudstack_ssh_keypair.keypair.private_key
}

resource "local_file" "output_target_sh" {
  count = var.generate.vm_info.vm_name == "zdm" ? 1 : 0
  filename = "${path.cwd}/scripts/zdm_target.sh"
  content = templatefile(
    "./tftpl/target.tftpl",
    {
      zdmip = cloudstack_static_nat.static_nat[0].vm_guest_ip
    }
  )
}

resource "local_file" "output_source_sh" {
  count = var.generate.vm_info.vm_name == "zdm" ? 1 : 0
  filename = "${path.cwd}/scripts/zdm_source.sh"
  content = templatefile(
    "./tftpl/source.tftpl",
    {
      zdmip = cloudstack_static_nat.static_nat[0].vm_guest_ip
    }
  )
}

resource "local_file" "output_target_cmd" {
  count = var.generate.vm_info.vm_name == "zdm" ? 1 : 0
  filename = "${path.cwd}/scripts/zdm_win_target.cmd"
  content = templatefile(
    "./tftpl/win_target.tftpl",
    {
      zdmip = cloudstack_static_nat.static_nat[0].vm_guest_ip
    }
  )
}

resource "local_file" "output_source_cmd" {
  count = var.generate.vm_info.vm_name == "zdm" ? 1 : 0
  filename = "${path.cwd}/scripts/zdm_win_source.cmd"
  content = templatefile(
    "./tftpl/win_source.tftpl",
    {
      zdmip = cloudstack_static_nat.static_nat[0].vm_guest_ip
    }
  )
}



output "result" {
  value = local.result
}