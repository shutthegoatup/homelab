variable "namespace" {
  type    = string
  default = "kube-prometheus"
}

variable "helm_version" {
  type    = string
  default = "47.1.0"
}

variable "grafana_host" {
  type    = string
  default = "grafana"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}

variable "secrets" {
  type    = list(any)
  default = ["gsuite"]
}

variable "oidc_endpoint" {
  type    = string
  default = "https://vault.shutthegoatup.com/v1/identity/oidc/provider/vault"
}
