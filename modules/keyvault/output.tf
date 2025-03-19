output "keyvault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "keyvault_id" {
  value = azurerm_key_vault.keyvault.id
}

output "keyvault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}

output "keyvault_access_policy_id" {
  value = azurerm_key_vault_access_policy.kv_access_policy.id
}