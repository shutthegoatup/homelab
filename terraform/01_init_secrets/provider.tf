terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}
