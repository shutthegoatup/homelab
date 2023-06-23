---
githubWebhookServer:
  enabled: true
  secret:
    enabled: true
    create: true
    github_webhook_secret_token: ${github-webhook-secret-token}
  ingress:
    ingressClassName: true
    enabled: true
    hosts: 
      - host: ${service-name}.${fqdn}
        paths:
          - path: /
            pathType: Prefix

authSecret:
  create: true
  github_app_id: ${github-app-id}
  github_app_installation_id: ${github-app-installation-id}
  github_app_private_key: ${github-app-private-key}

actionsMetricsServer:
  enabled: true
  secret:
    enabled: true
    create: true
    github_webhook_secret_token: ${github-webhook-secret-token}
  ingress:
    ingressClassName: true
    enabled: true
    hosts: 
      - host: ${metrics-service-name}.${fqdn}
        paths:
          - path: /
            pathType: Prefix

