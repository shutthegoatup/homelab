resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  for_each = var.secrets

  mount               = vault_mount.kvv2.path
  name                = each.key
  cas                 = 1
  delete_all_versions = true
  data_json = each.value
}