resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.service_name
  }
}

resource "helm_release" "helm" {
  name       = "radarr"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "radarr"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

