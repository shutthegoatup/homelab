---
expose:
  tls:
    enabled: false
  ingress:
    hosts:
      core: ${host}.${domain}
      notary: ${notary-host}.${domain}
externalURL: https://${host}.${domain}
harborAdminPassword: ${admin-password}

persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      size: 500Gi
      annotations: {}
    jobservice:
      jobLog:
        size: 100Gi
    database:
      size: 100Gi
    redis:
      size: 100Gi
    trivy:
      size: 500Gi
