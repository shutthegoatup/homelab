terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.20.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}
