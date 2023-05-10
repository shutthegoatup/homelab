---
ingress:
  main:
    enabled: true
    hosts: 
      - host: vaultwarden.secureweb.ltd
        paths:
          - path: /
            pathType: Prefix
            service:
              port: 80

env:
  TZ: "Europe/London" 

persistence:
  config:
    enabled: true
    type: pvc
    mountPath:   /config
    readOnly: false
    accessMode: ReadWriteOnce
 
