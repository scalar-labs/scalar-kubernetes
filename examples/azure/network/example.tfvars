name = "scalar-k8s-azure" # maximum of 82 characters

location = "West US 2"

public_key_path = "./example_key.pub"

# additional_public_keys_path = "./additional_public_keys"

private_key_path = "./example_key"

internal_domain = "internal.scalar-labs.com"

network = {
  # bastion_resource_type     = "Standard_D2s_v3"
  # bastion_resource_count    = "1"
  # bastion_access_cidr       = "0.0.0.0/0"
  # resource_root_volume_size = "16"
  bastion_enable_tdagent = "false"
  # user_name                 = "centos"
  # cidr                      = "10.42.0.0/16"
}
