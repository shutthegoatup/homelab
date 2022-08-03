resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "parca"
  repository = "https://parca-dev.github.io/helm-charts"
  chart      = "parca"
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

