resource "kubernetes_namespace" "ns" {
metadata {
  name = var.namespace
}
}

resource "helm_release" "cilium" {
  atomic     = true
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = "1.11.6"

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}
