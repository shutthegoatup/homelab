resource "helm_release" "cilium" {
  atomic     = true
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = "1.8.3"


  set {
    name  = "operator.numReplicas"
    value = 1
  }

  set {
    name  = "operator.numReplicas"
    value = 1
  }

  set {
    name  = "global.kubeProxyReplacement"
    value = "strict"
  }

  set {
    name  = "global.containerRuntime.integration"
    value = "crio"
  }
  set {
    name  = "k8s.requireIPv4PodCIDR"
    value = true
  }

  set {
    name  = "global.prometheus.enabled"
    value = true
  }

  set {
    name  = "global.hubble.enabled"
    value = true
  }

  set {
    name  = "global.hubble.relay.enabled"
    value = true
}

  set {
    name  = "global.hubble.ui.enabled"
    value = true
  }
  set {
    name  = "global.hubble.listenAddress"
    value = ":4244"
  }

  set {
    name  = "global.k8sServiceHost"
    value = "192.168.1.5"
  }

  set {
    name  = "global.k8sServicePort"
    value = "6443"
  }

}
