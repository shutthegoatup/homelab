output "homelab_client_id" {
  value = azuread_application.homelab.application_id
}

output "concourse_client_secret" {
  value = azuread_application_password.concourse.value
}

output "vault_client_secret" {
  value = azuread_application_password.vault.value
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}
