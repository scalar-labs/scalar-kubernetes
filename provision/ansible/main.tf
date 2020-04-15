locals {
  module_playbooks = "${path.module}/playbooks"
  playbook_path    = var.local_playbook_path == "" ? local.module_playbooks : var.local_playbook_path
}
