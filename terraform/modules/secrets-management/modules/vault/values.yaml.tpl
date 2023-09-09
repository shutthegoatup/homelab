---
gobal:
  serverTelemetry:
    prometheusOperator: true

server:
  updateStrategyType: "RollingUpdate"
  logLevel: trace
  logFormat: json
  enabled: true
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - host: ${host}.${domain}
  standalone:
    enabled: false
  ha:
    enabled: true
    setNodeId: true
    replicas: 3
    raft:
      enabled: true
      config: |
        ui = true
        plugin_directory = "/usr/local/libexec/vault"
        disable_mlock = true
        listener "tcp" {
          tls_disable = 1
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          # Enable unauthenticated metrics access (necessary for Prometheus Operator)
          telemetry {
            unauthenticated_metrics_access = "true"
          }
        }
        storage "raft" {
          path = "/vault/data"
          retry_join {
            auto_join = "provider=k8s label_selector=\"app.kubernetes.io/name=vault,component=server\" namespace=\"{{ .Release.Namespace }}\"" 
            auto_join_scheme = "http"
            auto_join_port = 8200
          }
        }

        service_registration "kubernetes" {}

        telemetry {
          prometheus_retention_time = "30s"
          disable_hostname = true
        }
  extraContainers: 
    - name: vault-unseal
      image: ghcr.io/bank-vaults/bank-vaults:1.20.4
      env:
        - name: VAULT_ADDR
          value: http://127.0.0.1:8200
      args:
        - unseal
        - --mode
        - k8s
        - --k8s-secret-name
        - vault-config-manager
        - --k8s-secret-namespace
        - vault
        - --raft-ha-storage
        - --raft-leader-address
        - "http://vault-active:8200"
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
