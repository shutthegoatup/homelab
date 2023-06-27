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

variable "secrets-list" {
  type = map(string)
  default = {github-app = "atlantis",
    atlantis = "atlantis",
    github-webhook-secret = "actions-runner-controller",
    arc-github-app = "actions-runner-controller"
  }
}

