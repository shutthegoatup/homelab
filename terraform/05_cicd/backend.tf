terraform {
  backend "kubernetes" {
    secret_suffix  = "cicd-state"
  }
}
