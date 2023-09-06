data "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
}

module "kube-prometheus-crds" {
  source = "../modules/kube-prometheus-crds"
}

module "cilium" {
  depends_on = [module.kube-prometheus-crds]
  source     = "../modules/cilium"
}

module "ingress" {
  depends_on = [module.cert-manager, module.metallb]
  source     = "../modules/ingress"

  team_email           = "letsencrypt@secureweb.ltd"
  cloudflare_api_token = yamldecode(data.kubernetes_secret_v1.input_vars.data.cloudflare).cloudflare_api_token
}

module "metallb" {
  depends_on = [module.cilium]
  source     = "../modules/metallb"
}

module "cert-manager" {
  depends_on = [module.cilium]

  source = "../modules/cert-manager"
}

module "echo" {
  depends_on = [module.ingress]
  source     = "../modules/echoserver"
}

module "vault" {
  depends_on = [module.ingress]
  source     = "../modules/vault"

  secrets = nonsensitive(data.kubernetes_secret_v1.input_vars.data)
}
