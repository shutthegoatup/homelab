module "kube-prometheus" {
  source = "../modules/kube-prometheus"
}

module "metrics-server" {
  source = "../modules/metrics-server"
}

module "vertical-pod-autoscaler" {
  source = "../modules/vertical-pod-autoscaler"
}

module "parca" {
  source = "../modules/parca"
}
