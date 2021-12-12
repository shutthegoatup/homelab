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
  version    = "1.10.4"

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

resource "kubernetes_config_map" "configmap" {
  metadata {
    name = "bgp-config"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  data = {
    "config.yaml" = file("${path.module}/config.yaml")
  }
}

