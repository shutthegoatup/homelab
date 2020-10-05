resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/loki/charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.loki.metadata.0.name
}
