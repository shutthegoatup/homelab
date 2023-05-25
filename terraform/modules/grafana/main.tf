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

    vm_chart_values = templatefile(
    "${path.module}/vm.yaml.tpl",
    local.template_vars
  )
}

resource "helm_release" "victoria-metrics" {
  name       = "victoria-metrics-cluster"
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart      = "victoria-metrics-cluster"
  namespace  = kubernetes_namespace.grafana.metadata.0.name

  values = [local.vm_chart_values]

}

