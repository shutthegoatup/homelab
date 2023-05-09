resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "vaultwarden"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "vaultwarden"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = "3.1.1"
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

