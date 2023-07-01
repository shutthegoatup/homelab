resource "kubernetes_namespace" "cert-manager" {
  metadata {

    name = var.namespace
  }
}


resource "helm_release" "cert-manager" {
  atomic     = true
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  version    = var.helm_version

  set {
    name  = "installCRDs"
    value = true
  }
}
