---
image:
  repository: docker.io/nginx
  pullPolicy: IfNotPresent

scheduledPolicies: 
- name: daily-policies
  concurrencyPolicy: Forbid
  schedule: "* * * * *"
  failedJobsHistoryLimit: 10
  successfulJobsHistoryLimit: 10
  policies:
    - name: ec2-tag-compliance-mark
      resource: ec2
      comment: |
        Mark non-compliant, Non-ASG EC2 instances with stoppage in 4 days
      filters:
        - "State.Name": running
        - "tag:aws:autoscaling:groupName": absent
        - "tag:c7n_status": absent



secret:
  enabled: true
  mountPath: /config
  secretName: custodian-aws-accounts
