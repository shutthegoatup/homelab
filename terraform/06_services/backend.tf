terraform {
  backend "kubernetes" {
    secret_suffix  = "services-state"
  }
}
