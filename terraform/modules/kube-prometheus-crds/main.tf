resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "kube-prometheus-crds"
  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "prometheus-operator-crds"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}

