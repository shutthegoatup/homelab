data "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
}

data "kubernetes_secret_v1" "vault_token" {
  metadata {
    name      = "vault-root-token"
    namespace = var.vault_namespace
  }
}
