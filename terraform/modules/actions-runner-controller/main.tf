locals {
  config = yamldecode(var.yaml)
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    github-app-id               = local.config.githubApp.id,
    github-app-installation-id  = local.config.githubApp.install_id,
    github-app-private-key      = local.config.githubApp.key,
    github-webhook-secret-token = local.config.githubApp.secret,
    fqdn                        = var.fqdn,
    service-name                = var.service-name,
    metrics-service-name        = var.metrics-service-name
  })]
}

