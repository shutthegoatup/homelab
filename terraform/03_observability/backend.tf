terraform {
  backend "kubernetes" {
    secret_suffix  = "observability-state"
  }
}
