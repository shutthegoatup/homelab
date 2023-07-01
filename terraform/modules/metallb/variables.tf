variable "namespace" {
  type    = string
  default = "metallb"
}

variable "helm_version" {
  type    = string
  default = "0.13.10"
}

variable "addresses" {
  type    = string
  default = "172.18.255.200-172.18.255.250"
}