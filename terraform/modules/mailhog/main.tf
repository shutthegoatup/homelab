resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "mailhog"
  chart      = "mailhog"
  repository = "https://codecentric.github.io/helm-charts"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    host   = var.host
    domain = var.domain
  })]
}
