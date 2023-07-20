variable "namespace" {
  type    = string
  default = "harbor"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}

variable "host" {
  type    = string
  default = "harbor"
}

variable "oidc_endpoint" {
  type    = string
  default = "https://vault.shutthegoatup.com/v1/identity/oidc/provider/vault"
}
