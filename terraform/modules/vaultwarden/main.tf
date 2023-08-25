resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "vaultwarden"
  repository    = "https://k8s-at-home.com/charts/"
  chart         = "vaultwarden"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = "5.3.2"
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

