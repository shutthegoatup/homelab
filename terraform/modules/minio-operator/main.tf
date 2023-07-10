resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "operator" {
  wait          = true
  wait_for_jobs = true
  name          = "minio-operator"
  repository    = "https://operator.min.io/"
  chart         = "operator"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //  version       = var.helm_version
  /*
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]*/
}
