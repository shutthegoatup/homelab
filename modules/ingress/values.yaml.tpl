---

controller:
  extraArgs: 
    default-ssl-certificate: "kube-ingress/wildcard-tls"
  config:
    force-ssl-redirect: "true"
  kind: Deployment
  service:
    type: LoadBalancer

defaultBackend:
  enabled: true
