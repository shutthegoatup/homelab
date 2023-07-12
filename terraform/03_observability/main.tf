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

module "vault-config" {
  depends_on = [data.kubernetes_secret_v1.vault_token]
  source     = "../modules/vault-config"

  secrets = nonsensitive(data.kubernetes_secret_v1.input_vars.data)
}

module "vault-secrets-operator" {
  depends_on = [data.kubernetes_secret_v1.vault_token, module.vault-config]
  source     = "../modules/vault-secrets-operator"
}
