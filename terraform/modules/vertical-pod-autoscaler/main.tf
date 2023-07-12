resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "vertical-pod-autoscaler"
  repository    = "https://cowboysysop.github.io/charts/"
  chart         = "vertical-pod-autoscaler"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}
