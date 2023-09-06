variable "namespace" {
  type    = string
  default = "vault"
}

variable "host" {
  type    = string
  default = "vault"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}

variable "helm_version" {
  type    = string
  default = "0.25.0"
}

variable "secrets" {
  type = map(any)
}