resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "secret" {
  metadata {
    name      = "cloudflare-secret"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  data = {
    api-token = var.cloudflare_api_token
  }
}

resource "helm_release" "nginx" {
  depends_on    = [helm_release.certs]
  wait          = true
  wait_for_jobs = true
  name          = "ingress-nginx"
  repository    = "https://kubernetes.github.io/ingress-nginx"
  chart         = "ingress-nginx"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  version       = var.helm_version
  values = [templatefile("${path.module}/values.yaml.tpl", {
  })]
}

resource "helm_release" "certs" {
  wait          = true
  wait_for_jobs = true
  name          = "ingress-certs"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-http
      spec:
        acme:
          # You must replace this email address with your own.
          # Let's Encrypt will use this to contact you about expiring
          # certificates, and issues related to your account.
          email: ${var.team_email}
          server: ${var.acme_server}
          privateKeySecretRef:
            # Secret resource that will be used to store the account's private key.
            name: letsencrypt-http
          # Add a single challenge solver, HTTP01 using nginx
          solvers:
          - http01:
              ingress:
                class: nginx
    - apiVersion: cert-manager.io/v1
      kind: Issuer
      metadata:
        name: letsencrypt-prod
      spec:
        acme:
          email: ${var.team_email}
          server: ${var.acme_server}
          privateKeySecretRef:
            name: letsencrypt-prod
          server: ${var.acme_server}
          solvers:
          - dns01:
              cloudflare:
                apiTokenSecretRef:
                  key: api-token
                  name: ${kubernetes_secret_v1.secret.metadata.0.name}
    - apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: wildcard-tls
      spec:
        dnsNames: ${jsonencode(var.domains_list)}
        issuerRef:
          kind: Issuer
          name: letsencrypt-prod
        secretName: wildcard-tls
          EOF
  ]
}
