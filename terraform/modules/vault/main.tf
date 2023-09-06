

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "vault"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version

  values = [templatefile("${path.module}/values.yaml.tpl", {
    host = var.host,
    domain         = var.domain
  })]
}

resource "helm_release" "unseal" {
  wait          = true
  wait_for_jobs = true
  name          = "vault-autounseal"
  repository    = "https://pytoshka.github.io/vault-autounseal"
  chart         = "vault-autounseal"
  namespace     = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/vault-autounseal.yaml.tpl", {

  })]
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "vault-configure"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  binary_data = {
    "vault-configure.yaml" = base64encode(
      templatefile("${path.module}/vault-configure.yaml.tpl", {
        oidc-client-id     = yamldecode(var.secrets.gsuite).client-id
        oidc-client-secret = yamldecode(var.secrets.gsuite).client-secret
        gsuite-service-account = jsonencode(yamldecode(var.secrets.gsuite).gsuite_service_account)
        host             = var.host
        domain             = var.domain
        }
      )
    )
  }
}

resource "kubernetes_service_account_v1" "vault_manager" {
  metadata {
    name      = "vault-manager"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
}

resource "kubernetes_deployment_v1" "vault_manager" {
  metadata {
    name      = "vault-manager"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vault-manager"
      }
    }

    template {
      metadata {
        labels = {
          app = "vault-manager"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.vault_manager.metadata.0.name
        container {
          image = "ghcr.io/bank-vaults/bank-vaults:1.20.4"
          name  = "configure"
          args = ["configure",
            "--mode",
            "k8s",
            "--k8s-secret-name",
            "vault-root-token",
            "--k8s-secret-namespace",
            "vault",
            "--vault-config-file",
          "/vault/autoconfig/vault-configure.yaml"]
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
    name      = kubernetes_service_account_v1.vault_manager.metadata.0.name
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  metadata {
    name      = kubernetes_service_account_v1.vault_manager.metadata.0.name
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.this.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault_manager.metadata.0.name
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
}

