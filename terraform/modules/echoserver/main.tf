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
    ingress_class_name = "nginx"
    rule {
      host = "${var.service_name}.${var.fqdn}"
      http {
        path {
          backend {
            service {
              name = "echoserver"
              port {
                number = 80
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
    selector = {
      app = "echoserver"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "echoserver"
    namespace = kubernetes_namespace.ns.metadata.0.name
    labels = {
      app = "echoserver"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "echoserver"
      }
    }
    template {
      metadata {
        labels = {
          app = "echoserver"
        }
      }
      spec {
        container {
          image = "kennethreitz/httpbin"
          name  = "httpbin"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
