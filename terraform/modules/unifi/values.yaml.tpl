---
ingress:
  main:
    enabled: true
    hosts:
      - 
        host: unifi.secureweb.ltd
        paths:
          - 
            path: /

persistence:
  config:
    enabled: true
    size: 100Gi
  unifi:
    enabled: true
    mountPath: /unifi
    accessMode: ReadWriteOnce
    size: 100Gi

service:
  main:
    annotations:
      metallb.universe.tf/allow-shared-ip: unifi
    enabled: true
    type: LoadBalancer
    ports:
      stun:
        enabled: false
        port: 3478
        protocol: UDP
      syslog:
        enabled: false
        port: 5514
        protocol: UDP
      discovery:
        enabled: false
        port: 10001
        protocol: UDP

  udp:
    annotations:
      metallb.universe.tf/allow-shared-ip: unifi
    enabled: true
    type: LoadBalancer
    # <your other service configuration>
    ports:
      stun:
        enabled: true
        port: 3478
        protocol: UDP
      syslog:
        enabled: true
        port: 5514
        protocol: UDP
      discovery:
        enabled: true
        port: 10001
        protocol: UDP
