resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "gha-runner-scale-set-controller" {
  wait          = true
  wait_for_jobs = true
  name          = "gha-runner-scale-set-controller"
  repository    = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart         = "gha-runner-scale-set-controller"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values-arc-set-controller.yaml.tpl", {
  })]
}

resource "helm_release" "gha-runner-scale-set" {
  depends_on    = [helm_release.gha-runner-scale-set-controller]
  wait          = true
  wait_for_jobs = true
  name          = "gha-runner-scale-set"
  repository    = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart         = "gha-runner-scale-set"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values-arc-set.yaml.tpl", {
    github-org-url       = "https://github.com/shutthegoatup",
    github-config-secret = "arc-github-app"
  })]
}
