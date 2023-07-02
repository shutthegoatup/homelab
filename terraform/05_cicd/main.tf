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

module "vault-config" {
  depends_on = [data.kubernetes_secret_v1.vault_token]
  source     = "../modules/vault-config"

  secrets = nonsensitive(data.kubernetes_secret_v1.input_vars.data)
}

module "vault-secrets-operator" {
  depends_on = [data.kubernetes_secret_v1.vault_token, module.vault-config]
  source     = "../modules/vault-secrets-operator"
}

module "atlantis" {
  depends_on = [module.vault-secrets-operator]
  source     = "../modules/atlantis"
}

module "actions-runner-controller" {
  depends_on = [module.vault-secrets-operator]
  source     = "../modules/actions-runner-controller"
}