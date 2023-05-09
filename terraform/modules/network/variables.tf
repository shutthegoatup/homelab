variable "base_domain" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "ingress" {
  type = list(any)
}

