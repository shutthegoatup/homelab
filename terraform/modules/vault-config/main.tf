
resource "vault_kv_secret_v2" "secrets" {
  for_each = var.secrets

  mount               = "kvv2"
  name                = each.key
  cas                 = 1
  delete_all_versions = true
  data_json           = sensitive(jsonencode(yamldecode(each.value)))
}

resource "vault_identity_oidc_scope" "profile" {
  name     = "profile"
  template = "{\"name\":{{identity.entity.aliases.${vault_jwt_auth_backend.oidc.accessor}.metadata.name}}}"

  description = "profile scope."
}

resource "vault_identity_oidc_scope" "email" {
  name     = "email"
  template = "{\"email\":{{identity.entity.aliases.${vault_jwt_auth_backend.oidc.accessor}.name}}}"

  description = "email scope."
}

resource "vault_identity_oidc_scope" "groups" {
  name     = "groups"
  template = "{\"groups\":{{identity.entity.groups.names}}}"

  description = "groups scope."
}


resource "vault_identity_oidc_provider" "vault" {
  name               = var.host
  https_enabled      = true
  issuer_host        = "${var.host}.${var.domain}"
  allowed_client_ids = ["*"]

  scopes_supported = [
    vault_identity_oidc_scope.profile.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.groups.name
  ]
}
