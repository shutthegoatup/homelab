---
githubConfigUrl: ${github-org-url}
githubConfigSecret: ${github-config-secret}

containerMode:
  type: kubernetes
  kubernetesModeWorkVolumeClaim:
    accessModes: ["ReadWriteOnce"]
    storageClassName: standard
    resources:
      requests:
      storage: 1Gi

template:
  spec:
    volumes:
      - name: work
        emptyDir:
          sizeLimit: 5000Mi