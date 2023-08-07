---
controller:
  metrics: 
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels: 
        release: kube-prometheus-stack

  replicas: 2
  extraArgs: 
    default-ssl-certificate: "kube-ingress/wildcard-tls"
  config:
    force-ssl-redirect: true
    use-proxy-protocol: true
    worker-processes: "8"
  kind: Deployment
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
  ingressClassResource:
    default: true
defaultBackend:
  enabled: true