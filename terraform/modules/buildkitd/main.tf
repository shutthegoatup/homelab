resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  wait          = true
  wait_for_jobs = true
  name          = "buildkitd"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "v0.3.2"
  namespace     = kubernetes_namespace.this.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: buildkitd
        name: buildkitd
      spec:
        replicas: 3
        selector:
          matchLabels:
            app: buildkitd
        template:
          metadata:
            labels:
              app: buildkitd
            annotations:
              container.apparmor.security.beta.kubernetes.io/buildkitd: unconfined
          # see buildkit/docs/rootless.md for caveats of rootless mode
          spec:
            containers:
              - name: buildkitd
                image: moby/buildkit:master-rootless
                args:
                  - --addr
                  - unix:///run/user/1000/buildkit/buildkitd.sock
                  - --addr
                  - tcp://0.0.0.0:1234
                  - --oci-worker-no-process-sandbox
                # the probe below will only work after Release v0.6.3
                readinessProbe:
                  exec:
                    command:
                      - buildctl
                      - debug
                      - workers
                  initialDelaySeconds: 5
                  periodSeconds: 30
                # the probe below will only work after Release v0.6.3
                livenessProbe:
                  exec:
                    command:
                      - buildctl
                      - debug
                      - workers
                  initialDelaySeconds: 5
                  periodSeconds: 30
                securityContext:
                  # Needs Kubernetes >= 1.19
                  seccompProfile:
                    type: Unconfined
                  # To change UID/GID, you need to rebuild the image
                  runAsUser: 1000
                  runAsGroup: 1000
                ports:
                  - containerPort: 1234
                volumeMounts:
                  # Dockerfile has `VOLUME /home/user/.local/share/buildkit` by default too,
                  # but the default VOLUME does not work with rootless on Google's Container-Optimized OS
                  # as it is mounted with `nosuid,nodev`.
                  # https://github.com/moby/buildkit/issues/879#issuecomment-1240347038
                  - mountPath: /home/user/.local/share/buildkit
                    name: buildkitd
            volumes:
              - name: buildkitd
                emptyDir: {}
    - apiVersion: v1
      kind: Service
      metadata:
        labels:
          app: buildkitd
        name: buildkitd
      spec:
        ports:
          - port: 1234
            protocol: TCP
        selector:
          app: buildkitd
          EOF
  ]
}
