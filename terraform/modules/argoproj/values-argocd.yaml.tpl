---
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2
  ingress:
    ingressClassName: nginx
    enabled: true
    hosts: 
      - ${host}.${domain}
  extraArgs: 
   - --insecure

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicaCount: 2

configs:
  cm:
    url: "https://${host}.${domain}"
    dex.config: |
      connectors:
       - type: oidc
         id: vault
         name: vault
         config:
           issuer: ${issuer}
           clientID: ${client-id}
           clientSecret: ${client-secret}
           requestedIDTokenClaims:
             groups:
               essential: true
           requestedScopes:
             - openid
             - user
           userNameKey: name
