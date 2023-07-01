---
ingress:
  enabled: true
  hosts:
    - 
      host: ${service_name}.${fqdn}
      paths:
        - 
          path: /
          pathType: Prefix

