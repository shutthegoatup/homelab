resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    cloudflare_zone_id = var.cloudflare_zone_id
    }
  )]
}

resource "kubernetes_secret_v1" "secret" {
  metadata {
    name      = "cloudflare"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  data = {
    cloudflare_email     = var.cloudflare_email
    cloudflare_api_token = var.cloudflare_api_token
  }

}
