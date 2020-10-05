resource "helm_release" "cilium" {
  atomic     = true
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = "1.9.1"


  set {
    name  = "operator.replicas"
    value = 1
  }

  set {
    name  = "masquerade"
    value = false
  }

  set {
    name  = "tunnel"
    value = "disabled"
  }

  set {
    name  = "autoDirectNodeRoutes"
    value = true
  }

  set {
    name  = "l7Proxy.enabled"
    value = true
  }


  set {
    name  = "installIptablesRules"
    value = false
  }

  set {
    name  = "hubble.enabled"
    value = true
  }

  set {
    name  = "hubble.relay.enabled"
    value = true
  }

  set {
    name  = "hubble.ui.enabled"
    value = true
  }
  set {
    name  = "hubble.listenAddress"
    value = ":4244"
  }

  set {
    name  = "k8sServiceHost"
    value = "192.168.1.1"
  }

  set {
    name  = "k8sServicePort"
    value = "6443"
  }

}
