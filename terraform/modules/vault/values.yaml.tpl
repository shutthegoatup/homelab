---

server:
  logLevel: trace
  logFormat: json
  enabled: true
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - host: ${service-name}.${fqdn}

csi:
  enabled: false

injector:
  enabled: false