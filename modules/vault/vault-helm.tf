resource "helm_release" "vault" {
  atomic     = true
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  version    = var.vault_helm_version

  set {
    name  = "server.ingress.enabled"
    value = false
  }

  set {
    name  = "ui.enabled"
    value = true
  }
}

