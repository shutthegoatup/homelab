resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "openebs"
  repository = "https://openebs.github.io/charts"
  chart      = "openebs"
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

resource "kubernetes_storage_class" "sc" {
  metadata {
    name = "openebs-zfspv"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner = "zfs.csi.openebs.io"
  reclaim_policy      = "Delete"
  parameters = {
    fstype = "zfs"
    poolname = "data"
    recordsize = "4k"
    thinprovision = "no"
  }
  allow_volume_expansion = "true"
  volume_binding_mode = "Immediate"
}


