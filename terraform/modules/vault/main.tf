resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  recreate_pods = true
  name          = "vault"
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  namespace     = kubernetes_namespace.this.metadata.0.name
  version       = var.helm_version

  values = [templatefile("${path.module}/values.yaml.tpl", {
    host               = var.host,
    domain             = var.domain,
    ingress-class-name = var.ingress_class_name
    init-volume        = kubernetes_config_map_v1.this.metadata.0.name,
    secret-volume      = kubernetes_secret_v1.this.metadata.0.name

  })]
}

resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = "vault-init"
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  binary_data = {
    "bootstrap.sh" = "${filebase64("${path.module}/bootstrap.sh")}"
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "vault-secrets"
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  data = {
    client-id              = yamldecode(var.secrets.gsuite).client-id
    client-secret          = yamldecode(var.secrets.gsuite).client-secret
    "service-account.json" = jsonencode(yamldecode(var.secrets.gsuite).gsuite_service_account)
  }
}

resource "kubernetes_role_v1" "this" {
  metadata {
    name = "vault"
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "vault"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "vault"
    namespace = "vault"
  }
}
