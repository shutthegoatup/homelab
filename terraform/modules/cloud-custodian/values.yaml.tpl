---
image:
  repository: cloudcustodian/c7n-org
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

args:
- "run"
- "-v"
- "-c /home/custodian/accounts/accounts.yaml"
- "-s /home/custodian/output"
- "-u /home/custodian/policies.yaml"

secret:
  enabled: true
  mountPath: /home/custodian/accounts
  secretName: custodian-aws-accounts