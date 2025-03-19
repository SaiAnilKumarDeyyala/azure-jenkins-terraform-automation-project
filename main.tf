data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

module "vnet" {
  source                  = "./modules/vnet"
  vnet_name               = var.vnet_name
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  address_space           = var.address_space
  subnet_name             = var.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
  nsg_name                = var.nsg_name
  tags                    = var.tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  keyvault_name       = var.keyvault_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
  object_id           = data.azurerm_client_config.current.object_id
}

# generate random password 
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "vm_password" {
  depends_on   = [module.keyvault]
  name         = "vm-password"
  value        = random_password.password.result
  content_type = "password"
  key_vault_id = module.keyvault.keyvault_id
}

module "vm" {
  depends_on            = [module.keyvault, azurerm_key_vault_secret.vm_password, module.vnet]
  source                = "./modules/vm"
  vm_name               = var.vm_name
  nic_name              = var.nic_name
  ip_configuration_name = var.ip_configuration_name
  subnet_id             = module.vnet.subnet_id
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  vm_size               = var.vm_size
  vm_username           = var.vm_username
  vm_password           = azurerm_key_vault_secret.vm_password.value
  tags                  = var.tags
  os_disk_name          = var.os_disk_name
}