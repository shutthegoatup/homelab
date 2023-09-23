resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  version    = "1.14.2"

  values = [templatefile("${path.module}/values.yaml.tpl", {
    }
  )]
}

/*
resource "helm_release" "ipam" {
  wait          = true
  wait_for_jobs = true
  name          = "cilium-ipam"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "v0.3.2"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: "cilium.io/v2alpha1"
      kind: CiliumL2AnnouncementPolicy
      metadata:
        name: policy1
      spec:
        nodeSelector:
          matchExpressions:
            - key: node-role.kubernetes.io/control-plane
              operator: DoesNotExist
        interfaces:
        - ^eth[0-9]+
        externalIPs: true
        loadBalancerIPs: true
    - apiVersion: "cilium.io/v2alpha1"
      kind: CiliumLoadBalancerIPPool
      metadata:
        name: "lb-pool"
      spec:
        cidrs:
        - cidr: "192.168.2.128/26"
        EOF
  ]
}
*/
