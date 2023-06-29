resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "gha-runner-scale-set-controller" {
  wait          = true
  wait_for_jobs = true
  name          = "arc"
  repository    = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart         = "gha-runner-scale-set-controller"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  #version       = var.helm_version
  values = [templatefile("${path.module}/values-arc-set-controller.yaml.tpl", {
  })]
}

resource "helm_release" "gha-runner-scale-set" {
  depends_on    = [helm_release.gha-runner-scale-set-controller]
  wait          = true
  wait_for_jobs = true
  name          = "arc-scale-set"
  repository    = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart         = "gha-runner-scale-set"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  #version       = var.helm_version
  values = [templatefile("${path.module}/values-arc-set.yaml.tpl", {
    github-org-url       = "https://github.com/shutthegoatup",
    github-config-secret = "arc-github-app"
  })]
}

resource "helm_release" "secrets" {
  for_each      = toset(var.secrets)
  wait          = true
  wait_for_jobs = true
  name          = each.key
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: secrets.hashicorp.com/v1beta1
      kind: VaultStaticSecret
      metadata:
        namespace: ${var.namespace}
        name: ${each.key}
      spec:
        mount: "kvv2"
        type: kv-v2
        path: ${each.key}
        refreshAfter: 60s
        destination:
          create: true
          name: ${each.key}
          EOF
  ]
}