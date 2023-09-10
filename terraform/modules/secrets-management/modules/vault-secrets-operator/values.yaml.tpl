---
defaultVaultConnection:
  enabled: true
  address: "http://vault.vault.svc.cluster.local:8200"
defaultAuthMethod:
  enabled: true
  kubernetes:
    role: vso
    serviceAccount: default
    tokenAudiences:
    - https://kubernetes.default.svc.cluster.local

