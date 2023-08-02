variable "namespace" {
  type    = string
  default = "mailhog"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}

variable "helm_version" {
  type    = string
  default = "5.2.3"
}
