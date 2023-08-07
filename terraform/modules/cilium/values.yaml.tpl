---
kubeProxyReplacement: strict
k8sServiceHost: "192.168.1.5"
k8sServicePort: "6443"

l2announcements:
  enabled: false

socketLB:
  enabled: true

externalIPs:
  enabled: true

nodePort:
  enabled: true

hostPort:
  enabled: true

ipam:
  mode: kubernetes

ingressController:
  enabled: true
  default: true
  enforceHttps: true
  loadbalancerMode: shared
#  defaultSecretNamespace: kube-ingress
#  defaultSecretName: wildcard-tls
  loadBalancerClass: nginx

apiserver:
  metrics:
    serviceMonitor:
      enabled: true
      labels: 
        release: kube-prometheus-stack

hubble:
  metrics: 
    enabled: {dns:query;ignoreAAAA,drop,tcp,flow,icmp,http}
    serviceMonitor:
      enabled: true
      labels: 
        release: kube-prometheus-stack

autoDirectNodeRoutes: true
routing-mode: native
ipv4NativeRoutingCIDR: 10.0.0.0/8

l7proxy: true
enableRuntimeDeviceDetection: true
tunnel: "disabled"
tunneling: false
routingMode: native-routing
native-routing-cidr: 10.0.0.0/8
bpf:
  masquerade: true

operator:
  # -- Enable the cilium-operator component (required).
  enabled: true

  # -- Roll out cilium-operator pods automatically when configmap is updated.
  rollOutPods: true
masquerade: true
