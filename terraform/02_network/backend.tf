terraform {
  backend "kubernetes" {
    secret_suffix = "bootstrap-state"
  }
}
