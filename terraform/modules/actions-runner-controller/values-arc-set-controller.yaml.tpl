---
serviceAccount:
  create: true
  name: gha

template:
  spec:
    serviceAccountName: ${service-account}
    containers:
      env: 
      - name: KUBE_IN_CLUSTER_CONFIG
        value: true


