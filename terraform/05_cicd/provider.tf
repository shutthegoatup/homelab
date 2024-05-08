terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.20.1"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.2"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}

provider "vault" {
  address                = "https://vault.shutthegoatup.com"
  token                  = data.kubernetes_secret_v1.vault_token.data["vault-root"]
  skip_child_token       = true
  skip_get_vault_version = true
}

provider "harbor" {
  url      = module.harbor.url
  username = module.harbor.username
  password = module.harbor.password
}

