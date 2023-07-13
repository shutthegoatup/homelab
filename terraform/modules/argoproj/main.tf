resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-cd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_cd_helm_version
  values        = [templatefile("${path.module}/values-argocd.yaml.tpl", {
    host   = "argocd"
    domain = var.domain
  })]
}

resource "helm_release" "argo-events" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-events"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-events"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_events_helm_version
  values        = [templatefile("${path.module}/values-argo-events.yaml.tpl", {
  })]
}

resource "helm_release" "argo-rollouts" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-rollouts"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-rollouts"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_rollouts_helm_version
  values        = [templatefile("${path.module}/values-argo-rollouts.yaml.tpl", {
  })]
}

resource "helm_release" "argo-workflows" {
  wait          = true
  wait_for_jobs = true
  name          = "argo-workflows"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-workflows"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argo_workflows_helm_version
  values        = [templatefile("${path.module}/values-argo-workflows.yaml.tpl", {
  })]
}

resource "helm_release" "argocd-apps" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-apps"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argocd_apps_helm_version
  values        = [templatefile("${path.module}/values-argocd-apps.yaml.tpl", {
  })]
}

resource "helm_release" "argocd-image-updater" {
  wait          = true
  wait_for_jobs = true
  name          = "argocd-image-updater"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-image-updater"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.argocd_image_updater_helm_version
  values        = [templatefile("${path.module}/values-argocd-image-updater.yaml.tpl", {
  })]
}
