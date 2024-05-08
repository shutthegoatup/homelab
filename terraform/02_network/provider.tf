terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}
