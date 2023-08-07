---
configInline:
  disablePermitInsecure: true
  tls:
    fallback-certificate: 
      name: wildcard-tls
      namespace: kube-ingress

contour:
  extraArgs: 
  - --useProxy
  ingressClass:
    name: nginx
    create: true
    default: true

