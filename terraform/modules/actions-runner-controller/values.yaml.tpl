---
githubWebhookServer:
  enabled: true
  secret:
    enabled: true
    create: false
    name: github-webhook-secret
  ingress:
    ingressClassName: nginx
    enabled: true
    hosts: 
      - host: ${service-name}.${fqdn}
        paths:
          - path: /
            pathType: Prefix

authSecret:
  enabled: true
  create: false
  name: arc-github-app

actionsMetricsServer:
  enabled: true
  secret:
    enabled: true
    create: false
    name: github-webhook-secret
  ingress:
    ingressClassName: nginx
    enabled: true
    hosts: 
      - host: ${metrics-service-name}.${fqdn}
        paths:
          - path: /
            pathType: Prefix

runner:
  statusUpdateHook:
    enabled: true

rbac:
  allowGrantingKubernetesContainerModePermissions: true