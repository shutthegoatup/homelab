resource "kubernetes_secret" "cloudflare_api" {
  metadata {
    name      = "cloudflare-secret"
    namespace = kubernetes_namespace.ingress.metadata.0.name
  }
  data = {
    "api-token" = var.cloudflare_api_token
  }
}

