resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  #atomic     = true
  name       = "tigera-operator"
  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = "v3.28.0"

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

