---
controller:
  metrics: 
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels: 
        release: kube-prometheus-stack
  hostNetwork: true
  hostPort:
    enabled: true
  replicas: 1
  extraArgs: 
    default-ssl-certificate: "kube-ingress/wildcard-tls"
  config:
    force-ssl-redirect: true
  kind: Deployment
  service:
    type: ClusterIP
  ingressClassResource:
    default: true
defaultBackend:
  enabled: true
