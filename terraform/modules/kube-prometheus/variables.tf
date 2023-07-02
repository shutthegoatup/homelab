variable "namespace" {
  type    = string
  default = "kube-prometheus"
}

variable "helm_version" {
  type    = string
  default = "47.1.0"
}

variable "grafana_service_name" {
  type    = string
  default = "grafana"
}

variable "fqdn" {
  type    = string
  default = "shutthegoatup.com"
}
