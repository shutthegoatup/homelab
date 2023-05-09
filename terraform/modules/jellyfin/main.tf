resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.service_name
  }
}

resource "helm_release" "helm" {
  name       = "jellyfin"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "jellyfin"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}



