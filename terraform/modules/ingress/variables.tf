variable "namespace" {
  type    = string
  default = "kube-ingress"
}

variable "helm_version" {
  type    = string
  default = "4.7.0"
}

variable "team_email" {
  type    = string
  default = "allan@shuthegoatup.com"
}

variable "acme_server" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cloudflare_api_token" {
  type = string
}

variable "domains_list" {
  type = list(string)
  default = [
    "*.notprod.positron.uk",
    "*.notprod.shutthegoatup.com",
    "*.shutthegoatup.com",
    "*.positron.uk",
    "*.adegnan.net",
    "*.secureweb.ltd",
    "shutthegoatup.com",
    "positron.uk",
    "adegnan.net",
  "secureweb.ltd"]
}