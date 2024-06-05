variable "namespace" {
  type    = string
  default = "arc"
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

variable "helm_version" {
  type    = string
  default = "0.7.0"
}

variable "secrets" {
  type    = list(any)
  default = ["arc-github-app", "github-webhook-secret"]
}
