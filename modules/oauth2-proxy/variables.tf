variable "helm_namespace_oauth2" {
  type    = string
  default = "oauth2-proxy"
}

variable "helm_version_oauth2" {
  type    = string
  default = "4.1.0"
}

variable "wildcard_dns" {
  type = string
}

variable "sso_internal_client_id" {
  type = string
}

variable "sso_internal_client_secret" {
  type = string
}

variable "sso_internal_cookie_secret" {
  type = string
}
