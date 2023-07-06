resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "gha-runner-scale-set-controller" {
  wait          = true
  wait_for_jobs = true
  name          = "arc"
  repository    = "../../../actions-runner-controller/charts"
  chart         = "gha-runner-scale-set-controller"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = "0.4.0"
  values = [templatefile("${path.module}/values-arc-set-controller.yaml.tpl", {
    service-account = kubernetes_service_account.sa.metadata.0.name
  })]
}

resource "helm_release" "gha-runner-scale-set" {
  depends_on    = [helm_release.gha-runner-scale-set-controller]
  wait          = true
  wait_for_jobs = true
  name          = "gha-runner-scale-set"
  repository    = "../../../actions-runner-controller/charts"
  chart         = "gha-runner-scale-set"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = "0.4.0"
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

resource "kubernetes_service_account" "sa" {
  metadata {
    namespace = kubernetes_namespace.ns.metadata.0.name
    name      = "yolo"
  }
}

resource "kubernetes_cluster_role_binding" "yolo" {
  metadata {
    name = "github-arc-controller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sa.metadata.0.name
    namespace = kubernetes_service_account.sa.metadata.0.namespace
  }
}
