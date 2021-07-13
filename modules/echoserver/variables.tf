variable "namespace" {
  type    = string
  default = "echoserver"
}

variable "container" {
  type    = string
  default = "k8s.gcr.io/echoserver:1.10"
}


