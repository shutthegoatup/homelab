resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

module "vault" {
  source = "./modules/vault"

  namespace = kubernetes_namespace.this.metadata.0.name
}

module "vault-config-manager" {
  source    = "./modules/vault-config-manager"

  namespace = kubernetes_namespace.this.metadata.0.name
  secrets = var.secrets
}

module "vault-secrets-operator" {
  source    = "./modules/vault-secrets-operator"

  namespace = kubernetes_namespace.this.metadata.0.name
}
