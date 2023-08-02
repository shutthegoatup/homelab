---
ingress:
  enabled: true
  hosts:
    - host: ${host}.${domain}
      paths:
        - path: "/"
          pathType: Prefix