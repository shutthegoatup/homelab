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

resource "vault_generic_endpoint" "plugin_name" {
  disable_read         = true
  disable_delete       = true
  path                 = "sys/plugins/catalog/secret/vault-plugin-harbor"
  ignore_absent_fields = true

  data_json = jsonencode({
    sha_256 = "71af59287f001791cfd2ee576076a43ace0031d4e9dd706a75e50e68452b9bc0"
    command = "vault-plugin-harbor"
  })
}

resource "vault_generic_endpoint" "kubernetes_secrets_reader" {
  disable_read         = true
  disable_delete       = true
  path                 = "sys/plugins/catalog/secret/vault-plugin-secrets-kubernetes-reader"
  ignore_absent_fields = true

  data_json = jsonencode({
    sha_256 = "a09457d4043afd3e6630ecc86cdee19585a46a605c8741530a66e14413c9b067"
    command = "vault-plugin-secrets-kubernetes-reader"
  })
}
