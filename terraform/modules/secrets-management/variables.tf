variable "namespace" {
  type    = string
  default = "vault"
}

variable "secrets" {
  type = map(any)
}
