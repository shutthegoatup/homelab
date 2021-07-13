---
kubeProxyReplacement: strict
k8s:
  requireIPv4PodCIDR: true
k8sServiceHost: "192.168.1.1"
k8sServicePort: "6443"

operator:
  enabled: true
  rollOutPods: true
  replicas: 1

devices: "enp39s0"

#bgp:
#  enabled: true
#  announce:
#    loadbalancerIP: true
