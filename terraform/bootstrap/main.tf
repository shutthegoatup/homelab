resource "kubernetes_secret_v1" "input_vars" {
  metadata {
    name = "input-vars"
  }
  data = {
    github-app = var.github-app
    atlantis   = var.atlantis
  }
}