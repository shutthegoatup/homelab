---
provider: cloudflare
source: service
env:
- name: CF_API_TOKEN
  valueFrom:
    secretKeyRef:
      name: cloudflare
      key: cloudflare_api_token
#- name: CF_API_EMAIL
#  valueFrom:
#    secretKeyRef:
#      name: cloudflare
#      key: cloudflare_email
extraArgs:
  - --zone-id-filter=${cloudflare_zone_id}
