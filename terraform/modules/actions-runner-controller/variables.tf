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

variable "helm_version" {
  type    = string
  default = "0.23.2"
}

variable "secrets" {
  type    = list(any)
  default = ["arc-github-app", "github-webhook-secret"]
}