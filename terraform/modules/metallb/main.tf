resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

resource "helm_release" "config" {
  depends_on    = [helm_release.helm]
  wait          = true
  wait_for_jobs = true
  name          = "metallb-config"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: metallb.io/v1beta1
      kind: IPAddressPool
      metadata:
        name: example
        namespace: ${var.namespace}
      spec:
        addresses:
        - ${var.addresses}
    - apiVersion: metallb.io/v1beta1
      kind: L2Advertisement
      metadata:
        name: empty
        namespace: ${var.namespace}
        EOF
  ]
}