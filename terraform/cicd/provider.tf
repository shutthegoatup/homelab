terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.17.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-main"

}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-main"
  }
}

provider "vault" {
  address                = module.vault.vault_address
  token                  = module.vault.vault_token
  skip_child_token       = true
  skip_get_vault_version = true
}