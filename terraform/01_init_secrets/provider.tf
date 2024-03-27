terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}
