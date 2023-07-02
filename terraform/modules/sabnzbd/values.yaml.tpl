---
ingress:
  main:
    enabled: true
    hosts: 
      - host: sabnzbd.secureweb.ltd
        paths:
          - path: /
            pathType: Prefix
            service:
              port: 8080

env:
  TZ: "Europe/London"
  HOST_WHITELIST_ENTRIES: "sabnzbd.secureweb.ltd"

persistence:
  config:
    enabled: true
    mountPath:   /config
    type: hostPath
    hostPath: /data/news/config/sabnzbd

  downloads:
    enabled: true
    mountPath: /downloads
    type: hostPath
    hostPath: /data/news/downloads

  media:
    enabled: true
    mountPath: /media
    type: hostPath
    hostPath: /data/news/media

podSecurityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
