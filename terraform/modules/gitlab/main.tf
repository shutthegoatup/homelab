resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  namespace  = kubernetes_namespace.gitlab.metadata.0.name

  set {
    name  = "nginx-ingress.enabled"
    value = false
  }

  set {
    name  = "global.edition"
    value = "ce"
  }

  set {
    name  = "certmanager.install"
    value = false
  }

  set {
    name  = "gitlab-runner.install"
    value = false
  }

  set {
    name  = "prometheus.install"
    value = false
  }

  set {
    name  = "global.hosts.domain"
    value = "secureweb.ltd"
  }

  set {
    name  = "global.ingress.enabled"
    value = "false"
  }

  set {
    name  = "global.ingress.configureCertmanager"
    value = "false"
  }

  set {
    name  = "global.appConfig.omniauth.providers[0].secret"
    value = kubernetes_secret.gitlab-azure-oidc.metadata.0.name
  }

  set {
    name  = "global.appConfig.omniauth.enabled"
    value = true
  }

  set {
    name  = "global.appConfig.omniauth.blockAutoCreatedUsers"
    value = false
  }

  set {
    name  = "global.appConfig.omniauth.allowSingleSignOn"
    value = "azure_oauth2"
  }

  set {
    name  = "global.appConfig.omniauth.autoLinkUser"
    value = true
  }

  set {
    name  = "global.appConfig.omniauth.autoSignInWithProvider"
    value = "azure_oauth2"
  }

  set {
    name  = "global.appConfig.omniauth.syncProfileFromProvider"
    value = "azure_oauth2"
  }

}

resource "kubernetes_secret" "gitlab-azure-oidc" {
  metadata {
    name      = "gitlab-azure-oidc"
    namespace = kubernetes_namespace.gitlab.metadata.0.name
  }
  data = {
    provider = <<EOT
name: azure_oauth2
args:
  client_id: ${var.azure_client_id}
  client_secret: ${var.azure_client_secret}
  tenant_id: ${var.azure_tenant_id}
EOT
  }
}

