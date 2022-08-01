resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.ns.metadata.0.name
}

resource "helm_release" "discovery" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.ns.metadata.0.name
}

resource "kubernetes_namespace" "nsi" {
  metadata {
    name = "istio-ingress"
  }
}

resource "helm_release" "gateway" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.nsi.metadata.0.name
}

resource "kubernetes_ingress_class_v1" "ic" {
  metadata {
    name = "istio"
  }

  spec {
    controller = "istio.io/ingress-controller"
  }
}
