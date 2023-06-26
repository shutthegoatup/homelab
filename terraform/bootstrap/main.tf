module "vault" {
  source = "../modules/vault"
}

module "vault-secrets-operator" {
  depends_on = [ module.vault.vault_token ]
  source = "../modules/vault-secrets-operator"

  secrets = {"github": var.github_yaml}

}

module "atlantis" {
  source = "../modules/atlantis"
  
  yaml = var.github_yaml
}
