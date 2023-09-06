plugins:
  - plugin_name: vault-plugin-harbor
    command: vault-plugin-harbor
    sha256: 71af59287f001791cfd2ee576076a43ace0031d4e9dd706a75e50e68452b9bc0
    type: secret
  - plugin_name: vault-plugin-secrets-kubernetes-reader
    command: vault-plugin-secrets-kubernetes-reader
    sha256: a09457d4043afd3e6630ecc86cdee19585a46a605c8741530a66e14413c9b067
    type: secret

auth:
  - type: oidc
    config:
      default_role: default 
      oidc_client_id: "${oidc-client-id}" 
      oidc_client_secret: "${oidc-client-secret}" 
      oidc_discovery_url: "https://accounts.google.com"
      provider_config:
        provider: gsuite
        gsuite_service_account: ${gsuite-service-account}
        gsuite_admin_impersonate: "allan@shutthegoatup.com"
        fetch_groups:             true
        fetch_user_info:          true
        groups_recurse_max_depth: 5       
    roles:
    - name: default
      role_type: oidc
      user_claim: email
      groups_claim: groups
      allowed_redirect_uris: 
        - "http://localhost:8250/oidc/callback" 
        - "https://${host}.${domain}/ui/vault/auth/oidc/oidc/callback" 
      policies: default 
      oidc_scopes:
        - email
        - groups
        - profile

groups:
  - name: superadmin
    policies:
      - superadmin
    type: external

group-aliases:
  - name: "superadmin@${domain}"
    mountpath: oidc
    group: superadmin

policies:
  - name: superadmin
    rules: path "*" {
             capabilities = ["create", "read", "update", "delete", "list"]
           }

secrets:
  - type: kv
    path: kvv2
    description: "KV Version 2 secret engine mount"
    options:
      version: 2

