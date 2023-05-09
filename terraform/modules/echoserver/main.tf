resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.ns.metadata.0.name
    annotations = {
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "0.0.0.0/0"
    }
  }
  spec {
    ingress_class_name = "istio"
    rule {
      host = "echo.secureweb.ltd"
      http {
        path {
          backend {
            service {
              name = "echoserver"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  spec {
    external_traffic_policy = "Local"
    type = "LoadBalancer"
    selector = {
      app = "echoserver"
    }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}


resource "helm_release" "helm" {
  name      = "${var.namespace}-secret-test"
  chart     = "${path.module}/helm"
  namespace = var.namespace

}
