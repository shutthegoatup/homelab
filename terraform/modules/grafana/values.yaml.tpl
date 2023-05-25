---
ingress:
  ingressClassName: nginx
  enabled: true
  hosts: 
    - ${service_name}.${base_domain}
  tls: 
    - hosts:
       - ${service_name}.${base_domain}
