---
server:
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - host: ${service-name}.${fqdn}

csi:
  enabled: true