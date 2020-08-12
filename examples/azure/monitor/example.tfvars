base = "default" # bai, chiku, sho

monitor = {
  # resource_type                 = "Standard_B2s"
  # resource_root_volume_size     = "64"
  # resource_count                = "1"
  # active_offset                 = "0"
  # enable_log_volume             = "true"
  # log_volume_size               = "500"
  # log_volume_type               = "Standard_LRS"
  # enable_tdagent                = "true"
  # set_public_access             = "false"
  # remote_port                   = 9090
  # enable_accelerated_networking = "false"
}

#slack_webhook_url = ""

targets = [
  "cassandra",
#   "scalardl",
]
