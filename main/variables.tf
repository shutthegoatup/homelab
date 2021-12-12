variable "base_domain" {
  type    = string
  default = "secureweb.ltd"
}

variable "concourse_helm_version" {
  type    = string
  default = "13.0.0"
}

variable "vault_helm_version" {
  type    = string
  default = "0.7.0"
}

variable "additional_owners" {
  type    = list(any)
  default = ["allan_secureweb.ltd#EXT#@allansecureweb.onmicrosoft.com"]
}

variable "azuread_tenant" {}
variable "azuread_client_id" {}
variable "azuread_client_secret" {}
variable "cloudflare_api_token" {}
variable "cloudflare_email" {}
variable "cloudflare_zone_id" {}
