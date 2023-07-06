---
serviceAccount:
  create: true
  name: gha

template:
  spec:
    serviceAccountName: ${service-account}

