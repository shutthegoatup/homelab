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
    containers:
    - name: runner
      image: ghcr.io/actions/actions-runner:latest
      env:
        - name: ACTIONS_RUNNER_CONTAINER_HOOKS
          value: /home/runner/k8s/index.js
        - name: ACTIONS_RUNNER_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER
          value: "true"
      volumeMounts:
        - name: work
          mountPath: /home/runner/_work
    volumes:
      - name: work
        ephemeral:
          volumeClaimTemplate:
            spec:
              accessModes: [ "ReadWriteOnce" ]
              storageClassName: standard
              resources:
                requests:
                storage: 1Gi
