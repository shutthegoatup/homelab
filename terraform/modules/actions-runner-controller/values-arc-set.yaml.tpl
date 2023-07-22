---
githubConfigUrl: ${github-org-url}
githubConfigSecret: ${github-config-secret}

maxRunners: 1000
minRunners: 5

containerMode:
  type: kubernetes
  kubernetesModeWorkVolumeClaim:
    accessModes: ["ReadWriteOnce"]
    storageClassName: standard
    resources:
      requests:
        storage: 1Gi
