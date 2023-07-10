terraform {
  backend "kubernetes" {
    secret_suffix = "init-secrets-state"
  }
}
