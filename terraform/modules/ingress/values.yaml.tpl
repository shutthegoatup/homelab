---

controller:
  extraArgs: 
    default-ssl-certificate: "kube-ingress/wildcard-tls"
  config:
    force-ssl-redirect: "true"
  kind: Deployment
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    annotations:
      external-dns.alpha.kubernetes.io/hostname: "*.secureweb.ltd"
  ingressClassResource:
    default: true


defaultBackend:
  enabled: true
