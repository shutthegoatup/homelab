resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  name          = "vault-secrets-operator"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault-secrets-operator"
  namespace     = var.namespace
  version       = var.helm_version

  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}
