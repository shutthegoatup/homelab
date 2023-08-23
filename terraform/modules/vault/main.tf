resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "vault"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version

  values = [templatefile("${path.module}/values.yaml.tpl", {
    service-name = var.service_name,
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "unseal" {
  wait          = true
  wait_for_jobs = true
  name          = "vault-autounseal"
  repository    = "https://pytoshka.github.io/vault-autounseal"
  chart         = "vault-autounseal"
  namespace     = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/vault-autounseal.yaml.tpl", {

  })]
}
