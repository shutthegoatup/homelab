resource "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
  data = {
    atlantis-github-app   = var.atlantis-github-app
    github-webhook-secret = var.github-webhook-secret
    arc-github-app        = var.arc-github-app
    gsuite                = var.gsuite
    cloudflare            = var.cloudflare
  }
}
