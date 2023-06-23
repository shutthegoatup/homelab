resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}



resource "helm_release" "helm" {
  wait       = true
  name       = var.service-name
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    service-name       = var.service-name
    fqdn               = var.fqdn
    default-tf-version = var.default_tf_version
    github-app         = var.github_app
    org-allow-list     = var.org_allow_list
    }
  )]
}

