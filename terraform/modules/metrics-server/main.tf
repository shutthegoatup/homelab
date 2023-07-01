resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "metrics-server"
  repository    = "https://kubernetes-sigs.github.io/metrics-server/"
  chart         = "metrics-server"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}
