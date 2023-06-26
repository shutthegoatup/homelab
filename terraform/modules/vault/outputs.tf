data "kubernetes_secret_v1" "vault_token" {
  depends_on = [helm_release.helm, helm_release.unseal]
  metadata {
    name = "vault-root-token"
    namespace = var.namespace
  }
  binary_data = {
    "root_token" = ""
  }
}

output "vault_address" {
    value = "https://${var.service_name}.${var.fqdn}"
}

output "vault_token" {
    value = base64decode(data.kubernetes_secret_v1.vault_token.binary_data["root_token"])
}