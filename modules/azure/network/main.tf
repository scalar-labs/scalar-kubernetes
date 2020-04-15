module "name_generator" {
  source = "../../universal/name-generator"

  name = var.name
}

resource "azurerm_resource_group" "resource_group" {
  name     = module.name_generator.name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.resource_group]
  name                = module.name_generator.name
  location            = var.location
  address_space       = [local.network.cidr]
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_servers         = []

  tags = {
    Terraform = "true"
    Name      = module.name_generator.name
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnet

  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefix       = each.value

  lifecycle {
    ignore_changes = [network_security_group_id]
  }
}

resource "azurerm_private_dns_zone" "dns" {
  name                = var.internal_domain
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  name                  = var.internal_domain
  resource_group_name   = azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

module "bastion" {
  source = "./bastion"

  network_name                = module.name_generator.name
  network_id                  = azurerm_virtual_network.vnet.id
  network_cidr                = local.network.cidr
  network_dns                 = basename(azurerm_private_dns_zone.dns.id)
  location                    = var.location
  resource_type               = local.network.bastion_resource_type
  bastion_access_cidr         = local.network.bastion_access_cidr
  resource_root_volume_size   = local.network.resource_root_volume_size
  public_key_path             = var.public_key_path
  private_key_path            = var.private_key_path
  additional_public_keys_path = var.additional_public_keys_path
  user_name                   = local.network.user_name
  subnet_id                   = azurerm_subnet.subnet["public"].id
  image_id                    = local.network.image_id
  enable_tdagent              = local.network.bastion_enable_tdagent
}
