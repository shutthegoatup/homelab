module "kube-prometheus" {
  source = "../modules/kube-prometheus"
}

module "metrics-server" {
  source = "../modules/metrics-server"
}

module "parca" {
  source = "../modules/parca"
}
