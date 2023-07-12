---
ingress:
  main:
    enabled: true
    hosts:
      -
        host: jellyfin.secureweb.ltd
        paths:
          -
            path: /

persistence:
  config:
    enabled: true
    mountPath: /config
    type: hostPath
    hostPath: /data/news/config/jellyfin

  cache:
    enabled: true
    mountPath: /cache
    type: hostPath
    hostPath: /data/news/cache

  transcode:
    enabled: true
    mountPath: /transcode
    type: hostPath
    hostPath: /data/news/transcode

  media:
    enabled: true
    mountPath: /media
    type: hostPath
    hostPath: /data/news/media

env:
  TZ: "Europe/London"

podSecurityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  # # Hardware acceleration using an Intel iGPU w/ QuickSync
  # # These IDs below should be matched to your `video` and `render` group on the host
  # # To obtain those IDs run the following grep statement on the host:
  # # $ cat /etc/group | grep "video\|render"
  # # video:x:44:
  # # render:x:109:

service:
  main:
    primary: true
    type: LoadBalancer
    annotations:
      metallb.universe.tf/allow-shared-ip: "jellyfin"
    ports:
      http:
        port: 8096
    externalTrafficPolicy: Local
  udp:
    enabled: true
    type: LoadBalancer
    annotations:
      metallb.universe.tf/allow-shared-ip: "jellyfin"
    ports:
      dnla-udp:
        enabled: true
        port: 1900
        protocol: UDP
        targetPort: 1900
      auto-discovery:
        enabled: true
        port: 7359
        protocol: UDP
        targetPort: 7359
    externalTrafficPolicy: Local

