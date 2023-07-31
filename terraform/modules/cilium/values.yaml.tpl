---
kubeProxyReplacement: strict
k8sServiceHost: "192.168.1.5"
k8sServicePort: "6443"

l2announcements:
  enabled: true

socketLB:
  enabled: false

externalIPs:
  enabled: true

nodePort:
  enabled: true

hostPort:
  enabled: true

enableRuntimeDeviceDetection: true

ipam:
  mode: kubernetes

ingressController:
  enabled: true
