module "atlantis" {
  source = "../modules/atlantis"
}

module "actions-runner-controller" {
  source = "../modules/actions-runner-controller"
}

module "harbor" {
  source = "../modules/harbor"
}

module "argopoj" {
  source = "../modules/argoproj"
}
