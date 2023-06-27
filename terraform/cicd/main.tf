data "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
}

module "vault" {
  source = "../modules/vault"
}

module "vault-secrets-operator" {
  depends_on = [module.vault.vault_token]
  source     = "../modules/vault-secrets-operator"

  secrets = nonsensitive(data.kubernetes_secret_v1.input_vars.data)
}

data "vault_kv_secret_v2" "github" {
  depends_on = [module.vault.vault-secrets-operator]
  mount      = "kvv2"
  name       = "atlantis-github-app"
}

module "atlantis" {
  depends_on = [module.vault-secrets-operator]

  source     = "../modules/atlantis"
  github_app = data.vault_kv_secret_v2.github.data_json
}

module "actions-runner-controller" {
  depends_on = [module.vault-secrets-operator]

  source = "../modules/actions-runner-controller"
}