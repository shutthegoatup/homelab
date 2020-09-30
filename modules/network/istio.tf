module "istio-git" {
  source = "git::https://github.com/istio/istio.git//manifests/charts/istio-operator?depth=1"
}

resource "helm_release" "istio-operator" {
  name   = "istio-operator"
  chart  = "${path.root}/.terraform/modules/network.istio-git/manifests/charts/istio-operator"
  atomic = true
  set {
    name  = "hub"
    value = "docker.io/istio"
  }

  set {
    name  = "tag"
    value = "1.7.2"
  }

  set {
    name  = "operatorNamespace"
    value = "istio-operator"
  }

  set {
    name  = "istioNamespace"
    value = "istio-system"
  }
}

#resource "kubernetes_namespace" "istio_namespace" {
#  metadata {
#    name = "istio-system"
#  }
#}

resource "kubernetes_manifest" "istio_config" {
  depends_on = [helm_release.istio-operator]
  provider   = kubernetes-alpha

  manifest = {
    apiVersion = "install.istio.io/v1alpha1"
    kind       = "IstioOperator"
    metadata = {
      name      = "controlplane"
      namespace = "istio-system"
    }
    spec = {
      profile = "demo"
    }
  }
}

