resource "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "standard"
  tenant_id           = var.tenant_id
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  depends_on              = [azurerm_key_vault.keyvault]
  key_vault_id            = azurerm_key_vault.keyvault.id
  tenant_id               = var.tenant_id
  object_id               = var.object_id
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  key_permissions         = ["Get", "List", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "UnwrapKey", "WrapKey"]
  certificate_permissions = ["Get", "List", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"]
}