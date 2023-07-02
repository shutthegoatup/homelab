---
gobal:
  serverTelemetry:
    prometheusOperator: true

server:
  logLevel: trace
  logFormat: json
  enabled: true
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - host: ${service-name}.${fqdn}
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        # Enable unauthenticated metrics access (necessary for Prometheus Operator)
        telemetry {
          unauthenticated_metrics_access = "true"
        }
      }
      storage "file" {
        path = "/vault/data"
      }

      telemetry {
        prometheus_retention_time = "30s"
        disable_hostname = true
      }

csi:
  enabled: false

injector:
  enabled: false

serverTelemetry:
  serviceMonitor:
    enabled: true
    selectors: {}
    interval: 30s
    scrapeTimeout: 10s
  prometheusRules:
      enabled: true
      selectors: {}
      rules: 
        - alert: vault-HighResponseTime
          annotations:
            message: The response time of Vault is over 500ms on average over the last 5 minutes.
          expr: vault_core_handle_request{quantile="0.5", namespace="mynamespace"} > 500
          for: 5m
          labels:
            severity: warning
        - alert: vault-HighResponseTime
          annotations:
            message: The response time of Vault is over 1s on average over the last 5 minutes.
          expr: vault_core_handle_request{quantile="0.5", namespace="mynamespace"} > 1000
          for: 5m
          labels:
            severity: critical