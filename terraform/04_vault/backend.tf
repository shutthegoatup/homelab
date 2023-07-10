terraform {
  backend "kubernetes" {
    secret_suffix = "vault-state"
  }
}
