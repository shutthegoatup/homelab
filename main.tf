locals {
  vault_redirect_uris     = ["http://localhost:8250/oidc/callback", "https://vault.${var.base_domain}/ui/vault/auth/oidc/oidc/callback"]
  concourse_redirect_uris = ["https://concourse.${var.base_domain}/sky/issuer/callback"]
  gitlab_redirect_uris    = ["https://gitlab.${var.base_domain}/users/auth/azure_oauth2/callback"]
  homelab_redirect_uris   = concat(local.concourse_redirect_uris, local.vault_redirect_uris, local.gitlab_redirect_uris)
}

module "azure" {
  source = "./modules/azure"

  homelab_redirect_uris = local.homelab_redirect_uris
  additional_owners     = var.additional_owners
}

module "concourse" {
  source = "./modules/concourse"

  concourse_helm_version = var.concourse_helm_version
  base_domain            = var.base_domain
  oidc_client_id         = module.azure.homelab_client_id
  oidc_client_secret     = module.azure.concourse_client_secret
  oidc_discovery_url     = "https://login.microsoftonline.com/${module.azure.tenant_id}/v2.0"
}

module "network" {
  source = "./modules/network"

  base_domain         = var.base_domain
  cloudflare_apitoken = var.cloudflare_apitoken

  ingress = [
    {
      name      = "emby"
      service   = "emby-embyserver"
      namespace = "news"
      port      = 8096
    },
    {
      name      = "concourse"
      service   = "concourse-web"
      namespace = "concourse"
      port      = 8080
    },
    {
      name      = "sabnzbd"
      service   = "sabnzbd"
      namespace = "news"
      port      = 8080
    },
    {
      name      = "sonarr"
      service   = "sonarr"
      namespace = "news"
      port      = 8081
    },
    {
      name      = "couchpotato"
      service   = "couchpotato"
      namespace = "news"
      port      = 80
    },
    {
      name      = "hubble"
      service   = "hubble-ui"
      namespace = "kube-system"
      port      = 80
    },
    {
      name      = "gitlab"
      service   = "gitlab-webservice"
      namespace = "gitlab"
      port      = 8181
    },
    {
      name      = "grafana"
      service   = "grafana"
      namespace = "grafana"
      port      = 80
    },
    {
      name      = "vault"
      service   = "vault"
      namespace = "vault"
      port      = 8200
    },
  ]
}

module "vault" {
  source = "./modules/vault"

  vault_helm_version  = var.vault_helm_version
  base_domain         = var.base_domain
  oidc_client_id      = module.azure.homelab_client_id
  oidc_client_secret  = module.azure.vault_client_secret
  oidc_discovery_url  = "https://login.microsoftonline.com/${module.azure.tenant_id}/v2.0"
  vault_redirect_uris = local.vault_redirect_uris
}

module "gitlab" {
  source = "./modules/gitlab"

  azure_client_id     = module.azure.homelab_client_id
  azure_client_secret = module.azure.concourse_client_secret
  azure_tenant_id        = module.azure.tenant_id
}

module "falco" {
  source = "./modules/falco"
}

module "loki" {
  source = "./modules/loki"
}

module "grafana" {
  source = "./modules/grafana"
}
