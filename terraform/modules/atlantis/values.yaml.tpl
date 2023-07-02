---
orgAllowlist: ${org-allow-list}
githubApp: ${github-app}
ingress:
    enabled: true
    ingressClassName: nginx
    path: /
    pathType: Prefix
    host: ${service-name}.${fqdn}
defaultTFVersion: ${default-tf-version}
enableKubernetesBackend: true
environment:
    KUBE_IN_CLUSTER_CONFIG: true
service:
    type: ClusterIP

hidePrevPlanComments: true
