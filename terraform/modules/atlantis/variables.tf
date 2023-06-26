variable "namespace" {
  type    = string
  default = "atlantis"
}

variable "service-name" {
  type    = string
  default = "atlantis"
}

variable "fqdn" {
  type    = string
  default = "shutthegoatup.com"
}

variable "default_tf_version" {
  type    = string
  default = "1.4.6"
}

variable "github_app" {
  type = string
}

variable "org_allow_list" {
  type    = string
  default = "github.com/shutthegoatup/*"
}