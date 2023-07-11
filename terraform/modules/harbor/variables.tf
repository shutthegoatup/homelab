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

variable "secrets" {
  type    = list(string)
  default = ["gsuite"]
}

variable "minio_tenant_helm_version" {
  type    = string
  default = "5.0.6"
}