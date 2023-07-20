terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.17.0"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "3.9.4"
    }
  }
}
