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

variable "secrets" {
  type = map(any)
}
