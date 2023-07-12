module "atlantis" {
  source     = "../modules/atlantis"
}

module "actions-runner-controller" {
  source     = "../modules/actions-runner-controller"
}

module "harbor" {
  source     = "../modules/harbor"
}

module "postgres-operator" {
  source = "../modules/postgres-operator"
}

module "minio-operator" {
  source = "../modules/minio-operator"
}

module "redis-operator" {
  source = "../modules/redis-operator"
}
