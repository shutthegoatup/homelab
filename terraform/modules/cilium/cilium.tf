resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = "1.13.4"

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}
