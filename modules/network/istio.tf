module "istio-git" {
  source = "git::https://github.com/istio/istio.git//manifests/charts/istio-operator?depth=1"
}

resource "helm_release" "istio-operator" {
  name  = "istio-operator"
  chart = "${path.root}/.terraform/modules/network.istio-git/manifests/charts/istio-operator"

  set {
    name  = "hub"
    value = "docker.io/istio"
  }

  set {
    name  = "tag"
    value = "1.6.0"
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

