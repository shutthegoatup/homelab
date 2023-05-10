variable "team_email" {
  type    = string
  default = "softwareteam@eposnow.com"
}

variable "wildcard_base_domain" {
  type = string
}

variable "wildcard_subrecord" {
  type = string
}

variable "ingress_namespace" {
  type = string
}

variable "acme_server" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
