---
expose:
  tls:
    enabled: false
    certSource: none
  ingress:
    hosts:
      core: ${host}.${domain}
externalURL: https://${host}.${domain}
harborAdminPassword: ${admin-password}
