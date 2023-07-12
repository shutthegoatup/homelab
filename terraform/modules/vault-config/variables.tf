variable "secrets" {
  type = map(any)
}

variable "host" {
  type    = string
  default = "vault"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}
