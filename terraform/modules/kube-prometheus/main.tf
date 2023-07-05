resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  depends_on    = [helm_release.secrets]
  wait          = true
  wait_for_jobs = true
  name          = "kube-prometheus-stack"
  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "kube-prometheus-stack"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    grafana-service-name = var.grafana_service_name,
    fqdn                 = var.fqdn
  })]
}

resource "helm_release" "secrets" {
  for_each      = toset(var.secrets)
  wait          = true
  wait_for_jobs = true
  name          = each.key
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: secrets.hashicorp.com/v1beta1
      kind: VaultStaticSecret
      metadata:
        namespace: ${var.namespace}
        name: ${each.key}
      spec:
        mount: "kvv2"
        type: kv-v2
        path: ${each.key}
        refreshAfter: 60s
        destination:
          create: true
          name: ${each.key}
          EOF
  ]
}
