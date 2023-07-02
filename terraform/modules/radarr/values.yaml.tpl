---
ingress:
  main:
    enabled: true
    hosts: 
      - host: radarr.secureweb.ltd
        paths:
          - path: /
            pathType: Prefix
            service:
              port: 7878

env:
  TZ: "Europe/London" 

persistence:
  config:
    enabled: true
    mountPath:   /config
    type: hostPath
    hostPath: /data/news/config/radarr

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
