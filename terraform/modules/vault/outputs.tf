output "vault_token" {
    value = data.kubernetes_secret_v1.vault_token.data
    sensitive = true
}