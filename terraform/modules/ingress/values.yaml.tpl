---
controller:
  replicas: 2
  extraArgs: 
    default-ssl-certificate: "kube-ingress/wildcard-tls"
  config:
    force-ssl-redirect: true
    use-proxy-protocol: true
  kind: Deployment
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
  ingressClassResource:
    default: true
defaultBackend:
  enabled: true
