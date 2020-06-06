resource "helm_release" "vault" {
  atomic     = true
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  version    = var.vault_helm_version

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "server.ingress.annotations"
    value = "kubernetes.io/ingress.class: istio"
  }

  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault.secureweb.ltd"
  }

  set {
    name  = "server.ingress.hosts[0].paths[0]"
    value = "/*"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "secureweb-tls"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "vault${var.base_domain}"
  }

  set {
    name  = "ui.enabled"
    value = true
  }

}

