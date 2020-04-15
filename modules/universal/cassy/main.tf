module "ansible" {
  source = "../../../provision/ansible"
}

resource "tls_private_key" "cassy_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "null_resource" "cassy_waitfor" {
  count = var.provision_count

  triggers = {
    triggers = join(",", var.triggers)
  }

  connection {
    bastion_host = var.bastion_host_ip
    host         = var.host_list[count.index]
    user         = var.user_name
    agent        = true
    private_key  = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = ["echo cassy host up"]
  }
}

resource "null_resource" "docker_install" {
  count = var.provision_count

  triggers = {
    triggers = null_resource.cassy_waitfor[count.index].id
  }

  connection {
    host        = var.bastion_host_ip
    user        = var.user_name
    agent       = true
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "cd ${module.ansible.remote_playbook_path}/playbooks",
      "ansible-playbook -u ${var.user_name} -i ${var.host_list[count.index]}, docker-server.yml -e enable_tdagent=${var.enable_tdagent ? 1 : 0} -e monitor_host=monitor.${var.internal_domain}",
    ]
  }
}

resource "null_resource" "cassy_container" {
  count = var.provision_count

  triggers = {
    triggers = null_resource.docker_install[0].id
  }

  connection {
    bastion_host = var.bastion_host_ip
    host         = var.host_list[count.index]
    user         = var.user_name
    agent        = true
    private_key  = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/provision"
    destination = "$HOME/cassy"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.cassy_private_key.private_key_pem}' > $HOME/.ssh/cassy.pem",
      "chmod 400 $HOME/.ssh/cassy.pem",
      "cd $HOME/cassy",
      "docker-compose up -d",
    ]
  }
}
