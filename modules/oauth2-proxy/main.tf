resource "kubernetes_namespace" "oauth" {
  metadata {
    name = var.helm_namespace_oauth2
  }
}

resource "helm_release" "oauth" {
  atomic     = true
  name       = "oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  namespace  = kubernetes_namespace.oauth.metadata.0.name
  version    = var.helm_version_oauth2

  values = [templatefile("${path.module}/oauth2-values.yaml.tpl", {
    sso_internal_client_id     = var.sso_internal_client_id,
    sso_internal_client_secret = var.sso_internal_client_secret,
    sso_internal_cookie_secret = var.sso_internal_cookie_secret,
    email_domain               = var.email_domain,
    wildcard_dns               = var.wildcard_dns,
    sso_internal_host          = var.sso_internal_host
    }
  )]
}
