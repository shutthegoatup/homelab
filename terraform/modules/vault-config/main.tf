locals {
  gsuite                 = yamldecode(var.secrets.gsuite)
  gsuite_service_account = jsonencode(local.gsuite.gsuite_service_account)
}

resource "vault_jwt_auth_backend" "oidc" {
  description        = "Shut The Goat Up"
  oidc_discovery_url = "https://accounts.google.com"
  path               = "oidc"
  type               = "oidc"
  oidc_client_id     = sensitive(local.gsuite.client-id)
  oidc_client_secret = sensitive(local.gsuite.client-secret)
  provider_config = {
    provider                 = "gsuite"
    gsuite_service_account   = sensitive(local.gsuite_service_account)
    gsuite_admin_impersonate = "allan@shutthegoatup.com"
    fetch_groups             = true
    fetch_user_info          = true
    groups_recurse_max_depth = 5
  }
  default_role = "default"
}

resource "vault_jwt_auth_backend_role" "role" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "default"
  token_policies = ["default"]
  oidc_scopes    = ["openid", "profile", "email"]
  user_claim     = "email"
  groups_claim   = "groups"
  role_type      = "oidc"
  claim_mappings = {
    "email": "email"
    "name": "fullname"
    "groups": "external_groups"
  }
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
    "https://vault.shutthegoatup.com/ui/vault/auth/oidc/oidc/callback"
  ]
}

resource "vault_identity_group" "superadmin" {
  name     = "superadmin"
  type     = "external"
  policies = [vault_policy.superadmin.name]
  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "superadmin_group_alias" {
  name           = "superadmin@${var.domain}"
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.superadmin.id
}

resource "vault_policy" "superadmin" {
  name = "superadmin"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secrets" {
  for_each = var.secrets

  mount               = vault_mount.kvv2.path
  name                = each.key
  cas                 = 1
  delete_all_versions = true
  data_json           = sensitive(jsonencode(yamldecode(each.value)))
}

resource "vault_identity_oidc_scope" "user" {
  name     = "user"
  template = "{\"email\":{{identity.entity.aliases.${vault_jwt_auth_backend.oidc.accessor}.name}}, \"groups\":{{identity.entity.groups.names}}, \"fullname\":{{identity.entity.aliases.${vault_jwt_auth_backend.oidc.accessor}.metadata.fullname}}}"

  description = "user scope."
}

resource "vault_identity_oidc_provider" "vault" {
  name               = var.host
  https_enabled      = true
  issuer_host        = "${var.host}.${var.domain}"
  allowed_client_ids = ["*"]

  scopes_supported = [vault_identity_oidc_scope.user.name]
}
