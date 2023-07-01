terraform {
  backend "kubernetes" {
    secret_suffix  = "bootstrap-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
