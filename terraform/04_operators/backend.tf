terraform {
  backend "kubernetes" {
    secret_suffix = "operators-state"
  }
}
