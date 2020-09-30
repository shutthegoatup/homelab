provider "kubernetes-alpha" {
  config_path = "~/.kube/config" // path to kubeconfig
}

provider "azuread" {
  client_id     = var.azuread_client_id
  client_secret = var.azuread_client_secret
  tenant_id     = var.azuread_tenant
}

provider "vault" {
  address = "https://vault.secureweb.ltd"
  token   = ""
}
