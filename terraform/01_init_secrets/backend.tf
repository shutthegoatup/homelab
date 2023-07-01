terraform {
  backend "kubernetes" {
    secret_suffix  = "init-secrets-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
