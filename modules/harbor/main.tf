resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.service_name
  }
}


resource "helm_release" "helm" {
  name       = "harbor"
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

