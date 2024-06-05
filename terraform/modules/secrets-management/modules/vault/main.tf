resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  name          = "vault"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  namespace     = var.namespace
  version       = var.helm_version

  values = [templatefile("${path.module}/values.yaml.tpl", {
    host   = var.host,
    domain = var.domain
  })]
}

resource "kubernetes_role_v1" "this" {
  metadata {
    name      = "vault-unseal-secret"
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  metadata {
    name      = "vault-unseal-secret"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.this.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "vault"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name      = "vault-cluster-role"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "vault"
    namespace = var.namespace
  }
}
