resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana.metadata.0.name

  values = [local.helm_chart_values]

}

locals {
  template_vars = {
    base_domain  = var.base_domain
    service_name = "grafana"
  }

  helm_chart_values = templatefile(
    "${path.module}/values.yaml.tpl",
    local.template_vars
  )
}

