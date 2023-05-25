locals {
  vault_redirect_uris     = ["http://localhost:8250/oidc/callback", "https://vault.${var.base_domain}/ui/vault/auth/oidc/oidc/callback"]
  concourse_redirect_uris = ["https://concourse.${var.base_domain}/sky/issuer/callback"]
  gitlab_redirect_uris    = ["https://gitlab.${var.base_domain}/users/auth/azure_oauth2/callback"]
  homelab_redirect_uris   = concat(local.concourse_redirect_uris, local.vault_redirect_uris, local.gitlab_redirect_uris)
}



module "cilium" {
  source = "../modules/cilium"
}

module "downloads" {
  source = "../modules/downloads"
}

module "metallb" {
  source = "../modules/metallb"
}

module "azure" {
  source = "../modules/azure"

  homelab_redirect_uris = local.homelab_redirect_uris
  additional_owners     = var.additional_owners
}

module "cilium" {
  source = "../modules/cilium"
}

module "parca" {
  source = "../modules/parca"
}

module "csi-driver-nfs" {
  source = "../modules/csi-driver-nfs"
}

module "cert-manager" {
  source = "../modules/cert-manager"
}

module "cloudflare" {
  source = "../modules/cloudflare"

  cloudflare_email     = var.cloudflare_email
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
}

module "external-dns" {
  source = "../modules/external-dns"

  cloudflare_email     = var.cloudflare_email
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
}

module "ingress" {
  depends_on = [module.cert-manager]
  source     = "../modules/ingress"

  base_domain         = var.base_domain
  cloudflare_api_token = var.cloudflare_api_token
}

module "sonarr" {
  source = "../modules/sonarr"
}

module "radarr" {
  source = "../modules/radarr"
}

module "sabnzbd" {
  source = "../modules/sabnzbd"
}

#module "loki" {
#  source = "../modules/loki"
#}

module "grafana" {
  source = "../modules/grafana"
  base_domain = var.base_domain
}

module "wildcard-cert" {
  source = "../modules/wildcard-cert"
  team_email                = "letsencrypt@secureweb.ltd"
  wildcard_base_domain      = "secureweb.ltd"
  wildcard_subrecord        = "*"
  ingress_namespace         = "kube-ingress"

}

module "vaultwarden" {
  source = "../modules/vaultwarden"
}

module "echo" {
  source = "../modules/echoserver"
}


module "kong" {
  source = "../modules/kong"
  namespace = "kong"
}
