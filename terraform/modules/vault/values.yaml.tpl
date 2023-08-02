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
  standalone:
    config: |
      ui = true
      plugin_directory = "/usr/local/libexec/vault"
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
  extraInitContainers: 
    - name: vault-plugin-harbor
      image: alpine
      command: [sh, -c]
      args:
        - cd /tmp &&
          wget https://github.com/manhtukhang/vault-plugin-harbor/releases/download/v0.2.0/vault-plugin-harbor_0.2.0_linux_amd64.tar.gz -O vault-plugin-harbor.tar.gz &&
          tar -xzf vault-plugin-harbor.tar.gz &&
          mv vault-plugin-harbor /usr/local/libexec/vault/vault-plugin-harbor &&
          chmod +x /usr/local/libexec/vault/vault-plugin-harbor
      volumeMounts:
        - name: plugins
          mountPath: /usr/local/libexec/vault
    - name: vault-plugin-secrets-kubernetes-reader
      image: alpine
      command: [sh, -c]
      args:
        - cd /tmp &&
          wget https://github.com/fybrik/vault-plugin-secrets-kubernetes-reader/releases/download/v0.5.0/vault-plugin-secrets-kubernetes-reader_0.5.0_Linux_x86_64.tar.gz -O vault-plugin-secrets-kubernetes-reader.tar.gz &&
          tar -xzf vault-plugin-secrets-kubernetes-reader.tar.gz &&
          mv vault/plugins/vault-plugin-secrets-kubernetes-reader /usr/local/libexec/vault/vault-plugin-secrets-kubernetes-reader &&
          chmod +x /usr/local/libexec/vault/vault-plugin-secrets-kubernetes-reader
      volumeMounts:
        - name: plugins
          mountPath: /usr/local/libexec/vault
  volumes:
    - name: plugins
      emptyDir: {}
  volumeMounts:
    - mountPath: /usr/local/libexec/vault
      name: plugins
      readOnly: true

csi:
  enabled: false

injector:
  enabled: false

serverTelemetry:
  serviceMonitor:
    enabled: true
    selectors: 
      release: kube-prometheus-stack
    interval: 30s
    scrapeTimeout: 10s
  prometheusRules:
      enabled: true
      selectors: 
        release: kube-prometheus-stack
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
