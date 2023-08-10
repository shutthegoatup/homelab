resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  wait          = true
  wait_for_jobs = true
  name          = "cloud-custodian"
  chart         = "../../../helm-charts/charts/cloud-custodian-cron"
  //chart         = "cloud-custodian-cron"
  namespace = kubernetes_namespace.ns.metadata.0.name
  version   = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}

resource "kubernetes_secret_v1" "secret" {
  metadata {
    name      = "custodian-aws-accounts"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  binary_data = {
    "accounts.yaml" = base64encode(<<-EOT
---
accounts:
  - account_id: "123123123123"
    name: account-1
    regions:
    - us-east-1
    - us-west-2
    role: arn:aws:iam::123123123123:role/CloudCustodian
    EOT
    )
  }
}
