resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "vault_identity_oidc_key" "key" {
  name               = "argocd"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

resource "vault_identity_oidc_client" "client" {
  name = "argocd"
  key  = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argocd.${var.domain}/api/dex/callback"
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


resource "helm_release" "argocd" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-cd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_cd_helm_version
  values        = [templatefile("${path.module}/values-argocd.yaml.tpl", {
    host   = "argocd"
    domain = var.domain
    issuer = "https://vault.shutthegoatup.com/v1/identity/oidc/provider/vault"
    client-id = data.vault_identity_oidc_client_creds.creds.client_id
    client-secret = data.vault_identity_oidc_client_creds.creds.client_secret
  })]
}

resource "helm_release" "argo-events" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-events"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-events"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_events_helm_version
  values        = [templatefile("${path.module}/values-argo-events.yaml.tpl", {
  })]
}

resource "helm_release" "argo-rollouts" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-rollouts"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-rollouts"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_rollouts_helm_version
  values        = [templatefile("${path.module}/values-argo-rollouts.yaml.tpl", {
  })]
}

resource "helm_release" "argo-workflows" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-workflows"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-workflows"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_workflows_helm_version
  values        = [templatefile("${path.module}/values-argo-workflows.yaml.tpl", {
  })]
}

resource "helm_release" "argocd-apps" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-apps"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argocd_apps_helm_version
  values        = [templatefile("${path.module}/values-argocd-apps.yaml.tpl", {
  })]
}

resource "helm_release" "argocd-image-updater" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-image-updater"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-image-updater"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argocd_image_updater_helm_version
  values        = [templatefile("${path.module}/values-argocd-image-updater.yaml.tpl", {
  })]
}
