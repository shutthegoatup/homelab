resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "helm_password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  special     = false
}

resource "helm_release" "helm" {
  name       = "harbor"
  chart      = "harbor"
  repository = "https://helm.goharbor.io"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    host           = var.host
    notary-host    = "notary"
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



resource "random_password" "robot_password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  special     = false
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
    kind      = "project"
    namespace = "*"
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
  depends_on           = [vault_generic_endpoint.harbor_enable]
  path                 = "harbor/config"
  ignore_absent_fields = true

  data_json = jsonencode({
    url      = "https://${var.host}.${var.domain}"
    username = "admin"
    password = resource.random_password.helm_password.result
  })
}

resource "vault_generic_endpoint" "harbor_role" {
  depends_on           = [vault_generic_endpoint.harbor_config]
  path                 = "harbor/roles/default"
  ignore_absent_fields = true

  data_json = jsonencode({
    ttl         = "60m",
    max_ttl     = "60m",
    permissions = <<-EOT
    [{
      "namespace": "*",
      "kind": "project",
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

resource "vault_kubernetes_auth_backend_role" "gha" {
  backend                          = "kubernetes"
  role_name                        = "gha"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 3600
  token_policies                   = ["default", vault_policy.gha.name]
  audience                         = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_policy" "gha" {
  name = "gha"

  policy = <<EOT
path "*" {
  capabilities = ["read", "list"]
}
EOT
}

data "vault_kv_secret_v2" "dockerhub" {
  mount = "kvv2"
  name  = "dockerhub"
}

resource "harbor_project" "main" {
  depends_on  = [vault_generic_endpoint.harbor_config]
  name        = "dockerhub-cache"
  registry_id = harbor_registry.docker.registry_id
}

resource "harbor_registry" "docker" {
  depends_on    = [vault_generic_endpoint.harbor_config]
  provider_name = "docker-hub"
  name          = "dockerhub-cache"
  endpoint_url  = "https://hub.docker.com"
  access_id     = data.vault_kv_secret_v2.dockerhub.data.username
  access_secret = data.vault_kv_secret_v2.dockerhub.data.token
}
