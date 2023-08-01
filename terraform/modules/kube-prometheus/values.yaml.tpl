---
crds:
  enabled: false

prometheus:
  prometheusSpec:
    podMonitorSelectorNilUsesHelmValues: false
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false


grafana:  
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - ${grafana-service-name}.${fqdn}
    path: /
    pathType: Prefix
  grafana.ini:
    server:
      root_url: https://${grafana-service-name}.${fqdn}
    auth:
      disable_login_form: true
    auth.google:
      enabled: true
      allow_sign_up: true
      auto_login: true
      client_id: notsecret
      client_secret: notsecret
      scopes: https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
      auth_url: https://accounts.google.com/o/oauth2/auth
      token_url: https://accounts.google.com/o/oauth2/token
      allowed_domains: ${fqdn}
      hosted_domain: ${fqdn}
      use_pkce: true
      role_attribute_path: contains(info.groups[*], 'superadmin') && 'Admin'
  envValueFrom:
    GF_AUTH_GOOGLE_CLIENT_ID:
      secretKeyRef:
        name: gsuite
        key: client-id
    GF_AUTH_GOOGLE_CLIENT_SECRET:
      secretKeyRef:
        name: gsuite
        key: client-secret
