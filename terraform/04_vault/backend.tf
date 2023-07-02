terraform {
  backend "kubernetes" {
    secret_suffix  = "vault-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
