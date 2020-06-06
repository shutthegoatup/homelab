resource "kubernetes_namespace" "concourse" {
  metadata {
    name = "concourse"
  }
}

resource "kubernetes_namespace" "harbor" {
  metadata {
    name = "harbor"
  }
}
