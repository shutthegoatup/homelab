---
kubeProxyReplacement: strict
k8sServiceHost: "192.168.1.5"
k8sServicePort: "6443"

socketLB:
  enabled: false

externalIPs:
  enabled: true

nodePort:
  enabled: true

hostPort:
  enabled: true

bpf:
  masquerade: false

ipam:
  mode: kubernetes

ingressController:
  enabled: false
