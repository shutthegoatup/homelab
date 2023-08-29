data "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
}
