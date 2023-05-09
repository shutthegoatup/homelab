module "atlantis" {
  source = "../modules/atlantis"
  
  yaml = var.github_yaml
}

module "vault" {
  source = "../modules/vault"
}
