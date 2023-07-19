resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  depends_on = [helm_release.secrets]
  name       = "harbor"
  chart      = "harbor"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
    host   = var.host,
    domain = var.domain
  })]
}

resource "helm_release" "secrets" {
  for_each      = toset(var.secrets)
  wait          = true
  wait_for_jobs = true
  name          = each.key
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "v0.3.2"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: secrets.hashicorp.com/v1beta1
      kind: VaultStaticSecret
      metadata:
        namespace: ${var.namespace}
        name: ${each.key}
      spec:
        mount: "kvv2"
        type: kv-v2
        path: ${each.key}
        refreshAfter: 60s
        destination:
          create: true
          name: ${each.key}
          EOF
  ]
}

resource "vault_identity_oidc_key" "key" {
  name               = "harbor"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

resource "vault_identity_oidc_client" "client" {
  name = "harbor"
  key  = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://${var.host}.${var.domain}/c/oidc/callback"
  ]
  assignments = [
    "allow_all"
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "random_password" "password" {
  length  = 12
  special = false
}

resource "harbor_project" "main" {
    provider = harbor

  depends_on = [ helm_release.helm ]
    name = "main"
}

resource "harbor_robot_account" "system" {
  provider = harbor
  depends_on = [ helm_release.helm ]

  name        = "example-system"
  description = "system level robot account"
  level       = "system"
  secret      = resource.random_password.password.result
  permissions {
    access {
      action   = "create"
      resource = "labels"
    }
    kind      = "system"
    namespace = "/"
  }
  permissions {
    access {
      action   = "push"
      resource = "repository"
    }
    access {
      action   = "read"
      resource = "helm-chart"
    }
    access {
      action   = "read"
      resource = "helm-chart-version"
    }
    kind      = "project"
    namespace = harbor_project.main.name
  }
  permissions {
    access {
      action   = "pull"
      resource = "repository"
    }
    kind      = "project"
    namespace = "*"
  }
}