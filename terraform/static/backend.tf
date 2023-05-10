terraform {
  backend "kubernetes" {
    secret_suffix    = "homelab-static"
    namespace = "atlantis"
  }
}
