variable "namespace" {
  type    = string
  default = "argoproj"
}

variable "domain" {
  type    = string
  default = "shutthegoatup.com"
}

variable "argo_cd_helm_version" {
  type    = string
  default = "5.38.1"
}

variable "argo_events_helm_version" {
  type    = string
  default = "2.4.0"
}

variable "argo_rollouts_helm_version" {
  type    = string
  default = "2.31.0"
}

variable "argo_workflows_helm_version" {
  type    = string
  default = "0.31.0"
}

variable "argocd_apps_helm_version" {
  type    = string
  default = "1.3.0"
}

variable "argocd_image_updater_helm_version" {
  type    = string
  default = "0.9.1"
}
