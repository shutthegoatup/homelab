resource "kubernetes_namespace" "falco" {
  metadata {
    name = "falco"
  }
}

resource "helm_release" "falco" {
  name       = "falco"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  namespace  = kubernetes_namespace.falco.metadata.0.name

  set {
    name  = "ebpf.enabled"
    value = true
  }
  set {
    name  = "docker.enabled"
    value = false
  }
  set {
    name  = "podSecurityPolicy.create"
    value = true
  }
  set {
    name  = "auditLog.enabled"
    value = true
  }
  set {
    name  = "scc.create"
    value = false
  }
}
