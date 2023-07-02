terraform {
  backend "kubernetes" {
    secret_suffix  = "cicd-state"
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}
