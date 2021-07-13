resource "helm_release" "wildcard-cert" {
  atomic    = true
  name      = "wildcard-cert"
  chart     = "${path.module}/helm"
  namespace = var.ingress_namespace

  values = [templatefile(
    "${path.module}/wildcardcert-values.yaml.tpl",
    {
      team_email = var.team_email
      wildcard_base_domain : var.wildcard_base_domain
      wildcard_subrecord : var.wildcard_subrecord
      acme_server : var.acme_server
    }
  )]
}

