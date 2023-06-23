module "vault" {
  source = "../modules/vault"

}

module "vault-secrets" {
  source = "../modules/vault-secrets"

  secrets = {"github": var.github_yaml}
}

module "atlantis" {
  source = "../modules/atlantis"
  
  yaml = var.github_yaml
}

module "actions-runner-controller" {
  source = "../modules/actions-runner-controller"
  
  yaml = var.github_yaml 
}

output "test" {
  value = module.vault.vault_token
}