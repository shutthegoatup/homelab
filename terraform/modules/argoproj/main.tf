resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo-cd" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-cd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argo-cd"
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "argo-events" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-events"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-events"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argo-events"
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "argo-rollouts" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-rollouts"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-rollouts"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argo-rollouts"
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "argo-workflows" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-workflows"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-workflows"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argo-workflows"
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "argocd-apps" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-apps"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argocd-apps"
    fqdn         = var.fqdn
  })]
}

resource "helm_release" "argocd-image-updater" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-image-updater"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-image-updater"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  //version       = var.helm_version
  values        = [templatefile("${path.module}/values.yaml.tpl", {
    service_name = "argocd-image-updater"
    fqdn         = var.fqdn
  })]
}
