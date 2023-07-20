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
