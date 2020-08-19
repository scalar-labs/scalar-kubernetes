module "network" {
  source = "git::https://github.com/scalar-labs/scalar-terraform.git//modules/azure/network?ref=master"

  # Required Variables
  name             = var.name
  region           = var.region
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  internal_domain  = var.internal_domain

  # Optional Variables
  network                     = var.network
  additional_public_keys_path = var.additional_public_keys_path
}
