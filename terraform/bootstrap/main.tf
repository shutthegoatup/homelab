module "atlantis" {
  source = "../modules/atlantis"
  
  yaml = var.github_yaml
}


resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  metadata {
    name = "atlantis-superpowers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "atlantis"
    namespace = "atlantis"
  }
}