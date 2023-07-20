resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "helm_password" {
  length  = 12
  special = false
}

resource "helm_release" "helm" {
  name       = "harbor"
  chart      = "harbor"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/values.yaml.tpl", {
    host           = var.host,
    domain         = var.domain
    admin-password = resource.random_password.helm_password.result
  })]
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

data "vault_identity_oidc_client_creds" "creds" {
  name = vault_identity_oidc_client.client.name
}

resource "harbor_config_auth" "oidc" {
  depends_on         = [helm_release.helm]
  auth_mode          = "oidc_auth"
  primary_auth_mode  = true
  oidc_name          = "vault"
  oidc_endpoint      = var.oidc_endpoint
  oidc_client_id     = data.vault_identity_oidc_client_creds.creds.client_id
  oidc_client_secret = data.vault_identity_oidc_client_creds.creds.client_secret
  oidc_scope         = "openid,user"
  oidc_verify_cert   = true
  oidc_auto_onboard  = true
  oidc_user_claim    = "fullname"
  oidc_groups_claim  = "groups"

  oidc_admin_group = "superadmin"
}

resource "random_password" "robot_password" {
  length  = 12
  special = false
}

resource "harbor_robot_account" "system" {
  depends_on = [helm_release.helm]

  name        = "system-robot"
  description = "system level robot account"
  level       = "system"
  secret      = resource.random_password.robot_password.result
  permissions {
    access {
      action   = "create"
      resource = "labels"
    }
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
    access {
      action   = "pull"
      resource = "repository"
    }
    kind      = "system"
    namespace = "/"
  }
}


resource "vault_generic_endpoint" "harbor_enable" {
  disable_read         = true
  disable_delete       = true
  path                 = "sys/mounts/harbor"
  ignore_absent_fields = true

  data_json = jsonencode({
    type = "vault-plugin-harbor"
  })
}

resource "vault_generic_endpoint" "harbor_config" {
  path                 = "harbor/config"
  ignore_absent_fields = true

  data_json = jsonencode({
    url = "https://${var.host}.${var.domain}"
    username = "admin"
    password = resource.random_password.helm_password.result
  })
}

resource "vault_generic_endpoint" "harbor_role" {
  depends_on = [vault_generic_endpoint.harbor_config ]
  path                 = "harbor/roles/default"
  ignore_absent_fields = true

  data_json = jsonencode({
    ttl = "60m",
    max_ttl = "60m",
    permissions = <<-EOT
    [{
      "namespace": "/",
      "kind": "system",
      "access": [
        {
          "action": "pull",
          "resource": "repository"
        },
        {
          "action": "push",
          "resource": "repository"
        },
        {
          "action": "create",
          "resource": "tag"
        },
        {
          "action": "delete",
          "resource": "tag"
        }
      ]
    }]
    EOT
  })
}


