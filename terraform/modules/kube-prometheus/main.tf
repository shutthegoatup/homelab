resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "kube-prometheus-stack"
  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "kube-prometheus-stack"
  namespace     = var.namespace
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    grafana-host   = var.grafana_host,
    domain         = var.domain
    client-id      = data.vault_identity_oidc_client_creds.creds.client_id
    client-secret  = data.vault_identity_oidc_client_creds.creds.client_secret
    oidc-endpoint  = var.oidc_endpoint
  })]
}

resource "vault_identity_oidc_key" "key" {
  name               = "grafana"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

resource "vault_identity_oidc_client" "client" {
  name = "grafana"
  key  = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://${var.grafana_host}.${var.domain}/login/generic_oauth"
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
