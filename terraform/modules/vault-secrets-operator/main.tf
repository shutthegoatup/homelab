resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "vault-secrets-operator" {
  wait          = true
  wait_for_jobs = true
  name          = "vault-secrets-operator"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault-secrets-operator"
  namespace     = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    vault-kube-auth-role       = vault_kubernetes_auth_backend_role.vso.role_name
    vault-kube-service-account = "vault-secrets-operator-controller-manager"
  })]

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
  data_json           = jsonencode(yamldecode(each.value))
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "kubernetes_secret_v1" "sa" {
  depends_on                     = [helm_release.vault-secrets-operator]
  wait_for_service_account_token = true
  metadata {
    name      = "vault-sa"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = "vault-secrets-operator-controller-manager"
    }
  }
  type = "kubernetes.io/service-account-token"
}

data "kubernetes_config_map_v1" "ca" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "kube-public"
  }
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc"
  kubernetes_ca_cert     = data.kubernetes_config_map_v1.ca.data["ca.crt"]
  token_reviewer_jwt     = kubernetes_secret_v1.sa.data["token"]
  disable_iss_validation = true
  issuer                 = "api"
}

resource "vault_kubernetes_auth_backend_role" "vso" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "vso"
  bound_service_account_names      = ["vault-secrets-operator-controller-manager"]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = ["default", vault_policy.vso.name]
  audience                         = "vault"
}

resource "vault_policy" "vso" {
  name = "vso"

  policy = <<EOT
path "${vault_mount.kvv2.path}/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "helm_release" "vso-secrets" {
  depends_on = [helm_release.vault-secrets-operator]
  for_each   = var.secrets-list
  name       = each.key
  repository = "https://dysnix.github.io/charts"
  chart      = "raw"
  version    = "0.3.1"
  namespace  = var.namespace
  values = [
    <<-EOF
    resources:
    - apiVersion: secrets.hashicorp.com/v1beta1
      kind: VaultStaticSecret
      metadata:
        namespace: ${var.namespace}
        name: ${each.key}
      spec:
        mount: ${vault_mount.kvv2.path}
        type: kv-v2
        path: ${each.key}
        refreshAfter: 60s
        destination:
          create: true
          namespace: ${each.value}
          name: ${each.key}
          EOF
  ]
}

resource "vault_audit" "aduit" {
  type = "file"

  options = {
    file_path = "/dev/stdout"
  }
}