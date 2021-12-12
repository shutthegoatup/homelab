config:
  clientID: ${sso_internal_client_id}
  clientSecret: ${sso_internal_client_secret}
  cookieSecret: ${sso_internal_cookie_secret}
  cookieName: ""
  #google: {}
    # adminEmail: xxxx
    # serviceAccountJson: xxxx
    # Alternatively, use an existing secret (see google-secret.yaml for required fields)
    # Example:
    # existingSecret: google-secret
  # Default configuration, to be overridden
  configFile: |-
    email_domains = [ "${email_domain}" ]
    upstreams = [ "file:///dev/null" ]
    whitelist_domains = "${wildcard_dns}"
    cookie_domains = "${wildcard_dns}"

ingress:
  enabled: true
  path: /
  # Only used if API capabilities (networking.k8s.io/v1) allow it
  pathType: ImplementationSpecific
  # Used to create an Ingress record.
  hosts:
    - "${sso_internal_host}${wildcard_dns}"
