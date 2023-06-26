resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = var.service_name
    namespace = var.namespace
  }
}
