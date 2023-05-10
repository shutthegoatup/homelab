resource "helm_release" "concourse" {
  name       = "concourse"
  repository = "https://concourse-charts.storage.googleapis.com/"
  chart      = "concourse"
  namespace  = "concourse"
  version    = var.concourse_helm_version

  set {
    name  = "web.ingress.enabled"
    value = false
  }

  set {
    name  = "concourse.web.externalUrl"
    value = "https://concourse.${var.base_domain}"
  }

  set {
    name  = "concourse.web.localAuth.enabled"
    value = false
  }

  set {
    name  = "concourse.web.auth.oidc.enabled"
    value = true
  }

  set {
    name  = "concourse.web.auth.oidc.displayName"
    value = "Azure AD"
  }

  set {
    name  = "concourse.web.auth.oidc.issuer"
    value = var.oidc_discovery_url
  }

  set {
    name  = "secrets.oidcClientId"
    value = var.oidc_client_id
  }

  set {
    name  = "secrets.oidcClientSecret"
    value = var.oidc_client_secret
  }

  set {
    name  = "concourse.web.auth.oidc.userNameKey"
    value = "name"
  }

  set {
    name  = "concourse.web.auth.oidc.groupsKey"
    value = "roles"
  }

  set {
    name  = "concourse.web.auth.mainTeam.oidc.group"
    value = "main_owners"
  }

  set {
    name  = "concourse.web.kubernetes.enabled"
    value = "true"
  }

  set {
    name  = "concourse.web.kubernetes.keepNamespaces"
    value = "false"
  }

}
