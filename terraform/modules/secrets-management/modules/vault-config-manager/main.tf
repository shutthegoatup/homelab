resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "vault-config-manager"
    namespace = var.namespace
  }
  binary_data = {
    "vault-configure.yaml" = base64encode(
      templatefile("${path.module}/values.yaml.tpl", {
        oidc-client-id         = yamldecode(var.secrets.gsuite).client-id
        oidc-client-secret     = yamldecode(var.secrets.gsuite).client-secret
        gsuite-service-account = jsonencode(yamldecode(var.secrets.gsuite).gsuite_service_account)
        host                   = var.host
        domain                 = var.domain
        }
      )
    )
  }
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = "vault-config-manager"
    namespace = var.namespace
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = "vault-config-manager"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vault-config-manager"
      }
    }

    template {
      metadata {
        labels = {
          app = "vault-config-manager"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.this.metadata.0.name
        init_container {
          image = "ghcr.io/bank-vaults/bank-vaults:1.20.4"
          name  = "init"
          args = ["init",
            "--mode",
            "k8s",
            "--k8s-secret-name",
            "vault-config-manager",
            "--k8s-secret-namespace",
          "vault"]
          env {
            name  = "VAULT_ADDR"
            value = "http://vault-internal:8200"
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "50Mi"
            }
          }
        }
        container {
          image = "ghcr.io/bank-vaults/bank-vaults:1.20.4"
          name  = "configure"
          args = ["configure",
            "--mode",
            "k8s",
            "--k8s-secret-name",
            "vault-config-manager",
            "--k8s-secret-namespace",
            "vault",
            "--vault-config-file",
          "/vault/autoconfig/vault-configure.yaml"]
          env {
            name  = "VAULT_ADDR"
            value = "http://vault-active:8200"
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "50Mi"
            }
          }
          volume_mount {
            mount_path = "/vault/autoconfig"
            name       = kubernetes_secret_v1.this.metadata.0.name
          }
        }
        volume {
          name = kubernetes_secret_v1.this.metadata.0.name
          secret {
            secret_name = kubernetes_secret_v1.this.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_role_v1" "this" {
  metadata {
    name      = kubernetes_service_account_v1.this.metadata.0.name
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "update"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  metadata {
    name      = kubernetes_service_account_v1.this.metadata.0.name
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.this.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata.0.name
    namespace = var.namespace
  }
}

