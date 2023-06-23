variable "namespace" {
  type = string
  default = "vault"
}

variable "service_name" {
  type = string
  default = "vault"
}

variable "fqdn" {
  type = string
  default = "shutthegoatup.com"
}

variable "helm_version" {
  type = string
  default = "0.24.1"
}
