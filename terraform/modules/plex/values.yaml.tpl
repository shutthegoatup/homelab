---
ingress:
  main:
    enabled: true
    ingressClassName: nginx
    hosts:
      -
        host: plex.secureweb.ltd
        paths:
          -
            path: /

persistence:
  config:
    enabled: true
    mountPath: /config
    accessMode: ReadWriteOnce
    size: 10Gi

  transcode:
    enabled: true
    mountPath: /transcode
    accessMode: ReadWriteOnce
    size: 100Gi

  media:
    enabled: true
    mountPath: /media
    type: hostPath
    hostPath: /data/news/media

service:
  main:
    primary: true
    type: LoadBalancer
    annotations:
      metallb.universe.tf/allow-shared-ip: "plex"
    ports:
      http:
        port: 32400
    externalTrafficPolicy: Local
  tcp:
    enabled: true
    type: LoadBalancer
    annotations:
      metallb.universe.tf/allow-shared-ip: "plex"
    ports:
      dnla-tcp:
        enabled: true
        port: 32469
        protocol: TCP
        targetPort: 32469
      roku:
        enabled: true
        port: 8324
        protocol: TCP
        targetPort: 8324
    externalTrafficPolicy: Local
  udp:
    enabled: true
    type: LoadBalancer
    annotations:
      metallb.universe.tf/allow-shared-ip: "plex"
    ports:
      dnla-udp:
        enabled: true
        port: 1900
        protocol: UDP
        targetPort: 1900
      bonjour:
        enabled: true
        port: 5353
        protocol: UDP
        targetPort: 5353
      gdm1:
        enabled: true
        port: 32410
        protocol: UDP
        targetPort: 32410 
      gdm2:
        enabled: true
        port: 32412
        protocol: UDP
        targetPort: 32412
      gdm3:
        enabled: true
        port: 32413
        protocol: UDP
        targetPort: 32413
      gdm4:
        enabled: true
        port: 32414
        protocol: UDP
        targetPort: 32414
    externalTrafficPolicy: Local

env:
  TZ: "Europe/London"
  ADVERTISE_IP: "https://plex.secureweb.ltd/,http://plex.secureweb.ltd:32400/,http://plex.secureweb.ltd:80/"
  ALLOWED_NETWORKS: "192.168.1.0/24"
  PLEX_PREFERENCE_1: "FriendlyName=plexy"
  PLEX_PREFERENCE_2: "EnableIPv6=0"
  PLEX_PREFERENCE_3: "LanNetworksBandwidth=192.168.1.0/24"
  PLEX_PREFERENCE_4: "TreatWanIpAsLocal=1"

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
