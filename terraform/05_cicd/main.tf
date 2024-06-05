



module "actions-runner-controller" {
  source     = "../modules/actions-runner-controller"

}


module "buildkitd" {
  source     = "../modules/buildkitd"

}

//module "spegel" {
//  source     = "../modules/spegel"

//}

/*
module "argopoj" {
  depends_on = [vault_kv_secret_v2.secrets]

  source = "../modules/argoproj"
}
*/
