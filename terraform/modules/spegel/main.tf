resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  name          = "spegel"
  repository    = "oci://ghcr.io/xenitab/helm-charts"
  chart         = "spegel"
  namespace     = kubernetes_namespace.this.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}




