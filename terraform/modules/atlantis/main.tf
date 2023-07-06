data "vault_kv_secret_v2" "github" {
  mount = "kvv2"
  name  = "atlantis-github-app"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = var.service-name
  repository    = "https://runatlantis.github.io/helm-charts"
  chart         = "atlantis"
  namespace     = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    service-name       = var.service-name
    fqdn               = var.fqdn
    default-tf-version = var.default_tf_version
    github-app         = sensitive(data.vault_kv_secret_v2.github.data_json)
    org-allow-list     = var.org_allow_list
    }
  )]
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  depends_on = [helm_release.helm]
  metadata {
    name = "atlantis-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "atlantis"
    namespace = var.namespace
  }
}
