resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "helm" {
  name       = "csi-driver-nfs"
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

resource "kubernetes_storage_class" "csi-nfs" {
  depends_on = [ helm_release.helm ]
  metadata {
    name = var.namespace
  }
  storage_provisioner = "nfs.csi.k8s.io"
  reclaim_policy      = "Delete"
  parameters = {
    server = "192.168.1.1"
    share  = "/data/nfs/pvc"
  }
  mount_options = ["nconnect=8", "nfsvers=4.1"]
}

