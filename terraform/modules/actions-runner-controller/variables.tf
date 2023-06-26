variable "namespace" {
  type    = string
  default = "actions-runner-controller"
}

variable "fqdn" {
  type    = string
  default = "shutthegoatup.com"
}

variable "service-name" {
  type    = string
  default = "arc"
}

variable "metrics-service-name" {
  type    = string
  default = "arc-metrics"
}

variable "yaml" {
  type = string
}

variable "helm_version" {
  type    = string
  default = "0.23.2"
}