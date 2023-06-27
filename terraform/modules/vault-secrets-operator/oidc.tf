locals {
  gsuite                 = yamldecode(var.secrets.gsuite)
  gsuite_service_account = jsonencode(local.gsuite.gsuite_service_account)
}

resource "vault_jwt_auth_backend" "oidc" {
  description        = "Shut The Goat Up"
  oidc_discovery_url = "https://accounts.google.com"
  path               = "oidc"
  type               = "oidc"
  oidc_client_id     = local.gsuite.client-id
  oidc_client_secret = local.gsuite.client-secret
  provider_config = {
    provider                 = "gsuite"
    gsuite_service_account   = sensitive(local.gsuite_service_account)
    gsuite_admin_impersonate = "allan@shutthegoatup.com"
    fetch_groups             = true
    fetch_user_info          = true
    groups_recurse_max_depth = 5
  }
  default_role = "admin"
}

resource "vault_jwt_auth_backend_role" "role" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "admin"
  token_policies = ["default", vault_policy.admin.name]

  user_claim   = "sub"
  groups_claim = "groups"
  role_type    = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
    "https://vault.shutthegoatup.com/ui/vault/auth/oidc/oidc/callback"
  ]
}

resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}