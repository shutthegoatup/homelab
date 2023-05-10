terraform {
  backend "kubernetes" {
    secret_suffix    = "homelab-static"
    config_path      = "~/.kube/config"
  }
}
