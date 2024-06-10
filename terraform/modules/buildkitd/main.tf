resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  name          = "buildkitd"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "v0.3.2"
  namespace     = kubernetes_namespace.this.metadata.0.name
  values = [
    <<-EOF

          EOF
  ]
}
