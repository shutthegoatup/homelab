data "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
}

data "kubernetes_secret_v1" "vault_token" {
  metadata {
    name      = "vault-config-manager"
    namespace = var.vault_namespace
  }
}
