---
grafana:  
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - ${grafana-service-name}.${fqdn}
    path: /
    pathType: Prefix
