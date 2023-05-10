terraform {
  backend "kubernetes" {
    secret_suffix    = "homelab-static"
    in_cluster_config = true
  }
}
