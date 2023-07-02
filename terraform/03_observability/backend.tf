terraform {
  backend "kubernetes" {
    secret_suffix  = "observability-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
