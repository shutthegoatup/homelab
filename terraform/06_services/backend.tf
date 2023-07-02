terraform {
  backend "kubernetes" {
    secret_suffix  = "services-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
