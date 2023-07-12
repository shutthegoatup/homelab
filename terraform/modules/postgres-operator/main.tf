resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "operator" {
  wait          = true
  wait_for_jobs = true
  name          = "postgres-operator"
  repository    = "https://opensource.zalando.com/postgres-operator/charts//postgres-operator"
  chart         = "postgres-operator"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //  version       = var.helm_version
  /*
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]*/
}

resource "helm_release" "operator-ui" {
  wait          = true
  wait_for_jobs = true
  name          = "postgres-operator-ui"
  repository    = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui"
  chart         = "postgres-operator-ui"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //  version       = var.helm_version
  /*
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]*/
}
