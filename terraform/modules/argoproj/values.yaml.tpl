---
ingress:
  className: nginx
  enabled: true
  host: ${service_name}.${fqdn}
