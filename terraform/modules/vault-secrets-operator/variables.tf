variable "namespace" {
  type    = string
  default = "vault-secrets-operator"
}

variable "helm_version" {
  type    = string
  default = "0.1.0"
}

variable "secrets" {
  type = map(any)
}
