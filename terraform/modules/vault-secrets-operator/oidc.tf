resource "vault_jwt_auth_backend" "oidc" {
    description = "OIDC backend"
    oidc_discovery_url = "https://accounts.google.com"
    path = "oidc"
    type = "oidc"
    oidc_client_id = "785078594887-ved0hp4i50lromi2njhrr42rnr0skh3s.apps.googleusercontent.com"
    oidc_client_secret = "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"
    provider_config = {
        provider = "gsuite"
        gsuite_admin_impersonate = "allan@shutthegoatup.com"
        fetch_groups = true
        fetch_user_info = true
        groups_recurse_max_depth = 5
    }
    default_role = "admin"
}

resource "vault_jwt_auth_backend_role" "role" {
  backend         = vault_jwt_auth_backend.oidc.path
  role_name       = "admin"
  token_policies  = ["default", vault_policy.admin.name]

  user_claim            = "sub"
  role_type             = "groups"
  allowed_redirect_uris = [ "http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
                            "http://localhost:8250/oidc/callback"
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