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

}
