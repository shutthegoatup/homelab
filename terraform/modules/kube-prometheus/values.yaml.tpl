---
crds:
  enabled: false

prometheus:
  prometheusSpec:
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false

grafana:  
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - ${grafana-host}.${domain}
    path: /
    pathType: Prefix
  grafana.ini:
    server:
      root_url: https://${grafana-host}.${domain}
    auth:
      disable_login_form: true
    auth.generic_oauth:
      enabled: true
      allow_sign_up: true
      auto_login: true
      client_id: ${client-id}
      client_secret: ${client-secret}
      scopes: openid profile email groups
      auth_url: https://vault.shutthegoatup.com/ui/vault/identity/oidc/provider/vault/authorize
      token_url: https://vault.shutthegoatup.com/v1/identity/oidc/provider/vault/token
      api_url: "https://vault.shutthegoatup.com/v1/identity/oidc/provider/vault/userinfo"
      allowed_domains: ${domain}
      use_pkce: true
      role_attribute_path: contains(groups[*], 'superadmin') && 'Admin'
      allow_assign_grafana_admin: true
