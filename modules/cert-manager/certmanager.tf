resource "helm_release" "cert-manager" {
  atomic     = true
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata.0.name
  version    = "v1.1.0"

  set {
    name  = "installCRDs"
    value = true
  }
}
