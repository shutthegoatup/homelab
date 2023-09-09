resource "vault_kv_secret_v2" "secrets" {
  for_each = nonsensitive(data.kubernetes_secret_v1.input_vars.data)

  mount               = "kvv2"
  name                = each.key
  cas                 = 1
  delete_all_versions = true
  data_json           = sensitive(jsonencode(yamldecode(each.value)))
}

data "vault_auth_backend" "oidc" {
  path = "oidc"
}

resource "vault_identity_oidc_scope" "profile" {
  name     = "profile"
  template = "{\"name\":{{identity.entity.aliases.${data.vault_auth_backend.oidc.accessor}.metadata.name}}}"

  description = "profile scope."
}

resource "vault_identity_oidc_scope" "email" {
  name     = "email"
  template = "{\"email\":{{identity.entity.aliases.${data.vault_auth_backend.oidc.accessor}.name}}}"

  description = "email scope."
}

resource "vault_identity_oidc_scope" "groups" {
  name     = "groups"
  template = "{\"groups\":{{identity.entity.groups.names}}}"

  description = "groups scope."
}


resource "vault_identity_oidc_provider" "vault" {
  name               = "vault"
  https_enabled      = true
  issuer_host        = "vault.shutthegoatup.com"
  allowed_client_ids = ["*"]

  scopes_supported = [
    vault_identity_oidc_scope.profile.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.groups.name
  ]
}

module "atlantis" {
  depends_on = [vault_kv_secret_v2.secrets]
  source     = "../modules/atlantis"

}

module "actions-runner-controller" {
  depends_on = [vault_kv_secret_v2.secrets]
  source     = "../modules/actions-runner-controller"

}

module "harbor" {
  depends_on = [vault_kv_secret_v2.secrets]
  source     = "../modules/harbor"

}

module "argopoj" {
  depends_on = [vault_kv_secret_v2.secrets]

  source = "../modules/argoproj"
}
