---
defaultVaultConnection:
  enabled: true
  address: "http://vault.vault.svc.cluster.local:8200"
defaultAuthMethod:
  enabled: true
  namespace: ${namespace}
  kubernetes:
    role: ${vault-kube-auth-role}
    tokenAudiences:
    - vault

