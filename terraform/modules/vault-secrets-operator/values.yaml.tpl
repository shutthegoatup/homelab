---
defaultVaultConnection:
  enabled: true
  address: "http://vault.vault.svc.cluster.local:8200"
defaultAuthMethod:
  enabled: true
  kubernetes:
    role: ${vault-kube-auth-role}
    serviceAccount: ${vault-kube-service-account}
    tokenAudiences:
    - vault
