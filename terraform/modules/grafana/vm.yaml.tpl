---
ingress:
  ingressClassName: nginx
  enabled: true
  hosts: 
    - vm.${base_domain}
  tls: 
    - hosts:
       - vm.${base_domain}
