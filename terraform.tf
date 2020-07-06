terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
    load_config_file = true
  }
}
