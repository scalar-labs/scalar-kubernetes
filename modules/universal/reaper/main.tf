module "ansible" {
  source = "../../../provision/ansible"
}

resource "null_resource" "reaper_waitfor" {
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
    inline = ["echo reaper host up"]
  }
}

resource "null_resource" "docker_install" {
  count = var.provision_count

  triggers = {
    triggers = null_resource.reaper_waitfor[count.index].id
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

resource "null_resource" "reaper_container" {
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
    destination = "$HOME"
  }

  provisioner "remote-exec" {
    inline = [
      "cd $HOME/provision",
      "echo export REAPER_JMX_AUTH_USERNAME= > env",
      "echo export REAPER_JMX_AUTH_PASSWORD= >> env",
      "if [[ -n '${var.cassandra_username}' ]]; then",
      "  echo export REAPER_CASS_AUTH_ENABLED=true >> env",
      "  echo export REAPER_CASS_AUTH_USERNAME=${var.cassandra_username} >> env",
      "  echo export REAPER_CASS_AUTH_PASSWORD=${var.cassandra_password} >> env",
      "fi",
      "echo export REAPER_STORAGE_TYPE=cassandra >> env",
      "echo export CASSANDRA_REPLICATION_FACTOR=${var.replication_factor} >> env",
      "echo export REAPER_CASS_CONTACT_POINTS=cassandra-lb.${var.internal_domain} >> env",
      "source ./env",
      "docker-compose up -d",
    ]
  }
}
