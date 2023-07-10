resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "operator" {
  depends_on = [ helm_release.secrets ]
  name       = "harbor"
  chart      = "https://github.com/goharbor/harbor-operator/releases/download/v1.3.0/harbor-operator-v1.3.0.tgz"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/operator-values.yaml.tpl", {
    namespace = kubernetes_namespace.ns.metadata.0.name
  })]
}

resource "helm_release" "harbor-config" {
  depends_on    = [ helm_release.operator ] 
  wait          = true
  wait_for_jobs = true
  name          = "harbor-config"
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: v1
      kind: Secret
      metadata:
        name: admin-core-secret
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      data:
        secret: SGFyYm9yMTIzNDU=
      type: Opaque
    - apiVersion: v1
      kind: Secret
      metadata:
        name: minio-access-secret
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      data:
        accesskey: YWRtaW4=
        secretkey: bWluaW8xMjM=
      type: Opaque
    - apiVersion: v1
      kind: Secret
      metadata:
        name: redis
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      type: Opaque
      stringData:
        password: MWYyZDFlMmU2N2Rm
    - apiVersion: databases.spotahome.com/v1
      kind: RedisFailover
      metadata:
        name: redis
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      spec:
        sentinel:
          replicas: 3
          extraVolumes:
          - name: redis
            secret:
              secretName: redis
              optional: false
          extraVolumeMounts:
          - name: redis
            mountPath: "/etc/secret"
            readOnly: true
        redis:
          replicas: 3
          extraVolumes:
          - name: redis
            secret:
              secretName: redis
              optional: false
          extraVolumeMounts:
          - name: redis
            mountPath: "/etc/secret"
            readOnly: true
    - apiVersion: "acid.zalan.do/v1"
      kind: postgresql
      metadata:
        name: acid-minimal-cluster
      spec:
        teamId: "acid"
        volume:
          size: 1Gi
        numberOfInstances: 2
        users:
          zalando:  # database owner
          - superuser
          - createdb
          foo_user: []  # role for application foo
        databases:
          foo: zalando  # dbname: owner
        preparedDatabases:
          bar: {}
        postgresql:
          version: "15"
    - apiVersion: v1
      kind: Secret
      metadata:
        name: harbor-test-ca
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      data:
        tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZpekNDQTNPZ0F3SUJBZ0lVU2Fva1FldWczaGJHQVF3U1BqaklsMmV1akl3d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1ZERUxNQWtHQTFVRUJoTUNRMDR4RERBS0JnTlZCQWdNQTFCRlN6RVJNQThHQTFVRUJ3d0lRbVZwSUVwcApibWN4RVRBUEJnTlZCQW9NQ0dkdmFHRnlZbTl5TVJFd0R3WURWUVFEREFoSVlYSmliM0pEUVRBZ0Z3MHlNREE0Ck1USXhNRFV5TkROYUdBOHlNVEl3TURjeE9URXdOVEkwTTFvd1ZERUxNQWtHQTFVRUJoTUNRMDR4RERBS0JnTlYKQkFnTUExQkZTekVSTUE4R0ExVUVCd3dJUW1WcElFcHBibWN4RVRBUEJnTlZCQW9NQ0dkdmFHRnlZbTl5TVJFdwpEd1lEVlFRRERBaElZWEppYjNKRFFUQ0NBaUl3RFFZSktvWklodmNOQVFFQkJRQURnZ0lQQURDQ0Fnb0NnZ0lCCkFPWlJaWWtGbVZCTmFiRVU0Y0RhcWEyN2s1K091VUhnMW9vU2NDbmJiQkZ4TkIyMi83Q3pYSVdPV21GQ1ZQalgKTHdBVjEzdTZwUWtNTWFqRHFQQS83bGR6OGFqWW05VlREZzgvcUdib2E2YW9OTzRHTExkeWlsaTY2R0xtSHBXawpCNi9KWjNKYUV2cHozOTQ4dk1pb0dDdXBjQnFFeGw4Z0hxcmdzeWpSOXVlcVM5bGU2Ni9nMWdEcVZtU0FVM3BQCndLa3dkUk1PaVFzeFNMOVRZL0lYYkNkVWVwc2xJQ2VHTEdqdjQvVUN0ZDlZVWhpSVJWOTdLc2dLRG4wQk8yOWMKVitXM0lDcW1yUDVsUUNYeUJQL0lPZW4zc0VoSlBDVTFuZUNZOWM2ODdKTlJJQ2VEWGUyTGJSUnRBcUIvblNXLwp1OGNzY3kwWFd6QjhicHN2dmU2d0hOMmNCU2thTXQ5MGN2N1JxMlpLNnRqMTltcHM1NXhoSjJibDFMTkNKbDZiClU2U0YvNXphZjQvdkF6SVJoUlpyMkJhQzlvdGc5U2ZQMXl2VHZBbVpUL1Z5T2h4R05QdGpZdU5rZm9YNVVSQ2QKWTB3N2l0S0VEZk82MDVJaXN1TEpGdUlhWVNMTzg1YWJSNmo3QzdNQnlWWHpxVEU1aGF1dFZlWno2SHNNOWxrbwp1dlQxejRZWm9hTVQrME4yT0dOcGtRdnlMTmZLM2djVitya0hkNURBSmdKWG1nNlVpZXh3UUtJZFIxNi9keWRPCkQ3RHpKTDVTU0tFbnNCaDA1NnRqQzU4NEdhVmljQ1U1WVBVdVBpSGx3dkRSREVLQytFNDQwdUxvQjUwTXE0TDgKOFI5Y3JZYklsWFkvdFF5eVdGL1FEbXFyZzMxeTVJRjBwV3JoOThoWm92eUxBZ01CQUFHalV6QlJNQjBHQTFVZApEZ1FXQkJTMUo2V3dyV1JPZlZ6UkNnVWtQeGVmMzV1ZW56QWZCZ05WSFNNRUdEQVdnQlMxSjZXd3JXUk9mVnpSCkNnVWtQeGVmMzV1ZW56QVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQ2IKR2RvUytOQmQ5KzJjUDViS1FFYjdsZXhXdEI5M1oyVWVsVkhhNllSRW90K2d1dU1yVkJnTGJvWmNGMS9pZzJIRApNV2l1bFIvQ2ZDN2tQbUxTWVZLRFlXWmJXRXBaUWhTNnYrSnlaQUkxY1lsU0d0cWVMcW41ZHBpUXZ2OTl2anJyCmFYTzV3a2U0Q3VZNnRqVTZzTkNhc2k5SDVXN09JRTlCRmxhSmtJeTh4SjNBeGpESlpDakthK2FsUFd0SnhGSSsKTHNKZkRmTFJTeERONlhPQ1hJTTZQM0NNVnYzemNudU9iQ3pwNUNKZWlULzA0eXdqWkJKQjB3bERVeGs3byt5WApjTzJUUEc4N01LOG1WelE3L1prZzgvUVZzTlNHcGlsSTBLYzVmNEtLR0NwUkR1RUx1dVNRbHNIdnZNaWRRcmQxCktDZHRHeDVIRFlJeDgrd0Z1RU5XTHZDVG4vd2dQQWtGbitqaU9Yb29CYmM4WllSU1NheW5mZzFtd0tpR2hPQ3EKK0hWV3hzdVNQSzFSZ2drTTFhMDJqTDZXby9wb0lsdkxvRFNhNjZDNHJoRnZmZGZWSlRJZWY2ZVBGb3k1Y0pNcwo4ZkZETU9SZ0Z4T29xbHliWGRyRmJsUEE0VzZUMjhLR0VwSmcyWVlDbmR3YkY3M0N6dkUrb2tlM254Uzcvakt4ClR4SFZJU01uY1ZONjNybnJoS1hNZEtCUzZvR1ErRkhXY0ZUNFhrbTBoU2drVURVTnZIMkxzaFUxREl5NGFrTmkKKzRhVlExdHlSd2huRjcrNVlUTDZnRTcremtZTXNOdkU2bDlFOU1MYW5TeUU5bnhPSDRKOHc0VUFuVTF2ZHZpQwpwQitXNXhsdVpvczZjMnUwbVk0d0UvdmVXV0lXRFdXdDFlT3J1RlBYUGc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
        tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRd0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1Mwd2dna3BBZ0VBQW9JQ0FRRG1VV1dKQlpsUVRXbXgKRk9IQTJxbXR1NU9manJsQjROYUtFbkFwMjJ3UmNUUWR0dit3czF5RmpscGhRbFQ0MXk4QUZkZDd1cVVKRERHbwp3Nmp3UCs1WGMvR28ySnZWVXc0UFA2aG02R3VtcURUdUJpeTNjb3BZdXVoaTVoNlZwQWV2eVdkeVdoTDZjOS9lClBMeklxQmdycVhBYWhNWmZJQjZxNExNbzBmYm5xa3ZaWHV1djROWUE2bFprZ0ZONlQ4Q3BNSFVURG9rTE1VaS8KVTJQeUYyd25WSHFiSlNBbmhpeG83K1AxQXJYZldGSVlpRVZmZXlySUNnNTlBVHR2WEZmbHR5QXFwcXorWlVBbAo4Z1QveURucDk3QklTVHdsTlozZ21QWE92T3lUVVNBbmcxM3RpMjBVYlFLZ2Y1MGx2N3ZITEhNdEYxc3dmRzZiCkw3M3VzQnpkbkFVcEdqTGZkSEwrMGF0bVN1clk5ZlpxYk9lY1lTZG01ZFN6UWlaZW0xT2toZitjMm4rUDd3TXkKRVlVV2E5Z1dndmFMWVBVbno5Y3IwN3dKbVUvMWNqb2NSalQ3WTJMalpINkYrVkVRbldOTU80clNoQTN6dXRPUwpJckxpeVJiaUdtRWl6dk9XbTBlbyt3dXpBY2xWODZreE9ZV3JyVlhtYytoN0RQWlpLTHIwOWMrR0dhR2pFL3RECmRqaGphWkVMOGl6WHl0NEhGZnE1QjNlUXdDWUNWNW9PbEluc2NFQ2lIVWRldjNjblRnK3c4eVMrVWtpaEo3QVkKZE9lcll3dWZPQm1sWW5BbE9XRDFMajRoNWNMdzBReENndmhPT05MaTZBZWRES3VDL1BFZlhLMkd5SlYyUDdVTQpzbGhmMEE1cXE0TjljdVNCZEtWcTRmZklXYUw4aXdJREFRQUJBb0lDQUV6YnNOUnU1K0NpVkxqaFRReThhNDhzClgzRUpnY3o0S04vZWswdUVpNld1YjBQVFE3UkZ4b1JUSXRuOTlya3JwZVdUWkZ0SHg3Y2pPSmNtNUFONGNpTUEKOEEzMmF0cGZZdnUzdEl6UzFzbkFyQmthT21YbGRVRnk3Z1hDNFVYeWZSWXVVYlVaVmVmNkx5VE1nL3M2RFFiVQovakg3U08rSm1uSlBsYm56aHo5NzF0L3RDeDJnSEFvbUtUcFVrSWJxZ2xKemR6NHF4WlRVbDRBeFpkTHQrZ3VOCjUzUktpVlpuTWY2NnZ3bU9JLzhxVEFzZnZuYkVkVnhYN3NuTVZYY3VDNjcrMDE4b1MrYUJCMDBpWElTMjNveXoKT1VLR0hlb1U0R0NJNnM1WXdXSFAycmtVMzQxYno4VFhNOTgzZHN1WUZpTzdNNXhDaFEzREdHMzFHcDdDYW43dgpaeWVCaGwxeXBvZHVVYjQxUW0vRzB4S3gyelRyeWR6RXBOZUNidCtJazhjMDBvMW1JTXRVdkc3ekVzeFFBc2M2CnBGMTZEK0lEZ01UdzZLM1FuYmpiMzE2QlFxQzhoOW9PMkJYZ1c0UGdnVVphWjByS2RTMGs2Ylo1dnE3T3I2Qk4KZW8zamlwbjlxZWxlODZHaU5aMmF5cmNyck50M2VlSkdmK3h0ZXBMVERYU2krTCt2OS8rd056bFZ1Vm5VWVIyWQpLdC84Y1htR2tvcmtDK2djN0RYbnhiMllaRTE2RDZWcE5rcEd0QlZpQTVZMXdDeGdtcVNRbDRneGNMZWE2RUNWCkVCeFhqOWFvWjZJTGlYRnRwRFZtVStVVVZZNmVPMSsxSVBqNmFiNEdibEhPRE5BcFJGekpUS29oS2tBY0ViZXkKNi90NW1KNGRjZXAxRm5veTFDQXhBb0lCQVFENXk4NU4xQmgwMCtwdmpEU3VWdkwrcll4VlFZakdTLzFtWlYvYgorSXo3N3hBOTlzU2ZkSzNWS2UxSk15bFg0Zkx4SEo2TG9kYUxoMysyU3U3MTNqSTQzUTJ4bFRiSURJeFQxdEJECjhucEpzNHI2YktINHh2NGYyby9RYzhnWjQwTEg4bkdTc1VPZUdEYU1DTlN3ZjNxR0FnMFlJY2EzSkhQUnJBdk8KZE9OZmFicWVyaVFYcUt4VzFObUxhdGtaVTI0S0twWmcra0oyV2picGl3dms0SFM4Zmdwb0puRkd2L3I5ZEJnQgprQW8yeGpTOEJMZFU5cno2SjFpQ1I2ZURPN3dhZCtiWmlIVFVBSXFyUmRKYU5lSmFTS2dwYUpheEp6cUNQODBkCjd4LzFKQTBSY3NvUU5VMHVpeml5MmdKUCt4bVgvN2FMNzJCdDBJYzZtT1VicTlwSEFvSUJBUURzQ2IvVklLSUwKUWNrYlZpSW1DanFuQllVQW5RZmpRaUlpaTFqV3lCOGVvOXlqVVM2b0JNMTdOOVJrU1psVHZtMzBGcjdsVXAwKwpNUmVmVkxLdG5EYUhQOXZqWTVvQ0xObEs3Ryt1U0hZRTl3NFI0T2lzelYzeWl4L3JVV0cramVKRHhGeGVnUFJKCnc1cUExclZUblcvVGlMc0ltUG94RG1HRUNKRjBhTi83dmMvaW51ZS9LVGZSc2J6OThmTWd3SUltTHVBT0UrekwKMzRPRHdMRU1BbjZCaG5sTUlweE8xSDU1QUdVOEc0MnNjM1ZwRkcvMHBWYU14TzR5VnQzaDY3U2JJV05zT1hBYgpPdm43L04xVlQ5TUtWUkFVMTZ2ZnJENW82TjRPZnd0eW1TcVhHUFBhTXRBRDYwM0l6UWp2ajV2WCsvRDZEMVJSCjBSOEpNYzVxRVdtZEFvSUJBUURqRVdiSnpNRW1nZlNiemNHZHNTQldiZ0FoQjkrREVsU1luaEpUYlU4TFBMZHcKL0Q2a0RIWndUUnFMN2R2cExWV2Y0N29qaDh2MUxnamo5cDNlRmt0azhWeWZUdHByWXl5MGtaTGtFU2tra2ZjRgp5WFk3SlBpZ2tCY25EL2lYdjhSVzZZWmdLSThreVRIY2ZiS0pkbmcwRk8wK1FJWFl1V1FtOXRRTXFxaDlkU2pWClVjc3hUbnpLdWRXL0xET0pHQlB4WGVFdzZvMDc5S255QmhtYnhvV1hTcU8vSlNMWGczQnVzUGVaaEF3azJtdloKZGhnSlBmbHZGQkVhN0hQVGtadGVIQnhYSmZtOU5YallWREh4R3daVnQ3SlZZZU9KeWZVZnJVdVJxR3RPZGFVRApkV3RFN0k3cWZsZmVETnNKUldKd2oxeXJPOEJXVXJaNmg3M01ONTNGQW9JQkFRQ042OHJCTGc3Z3I5eG9xR0I5CitOYU5TRjlSSUJuM0JmT2FTNmpOODZQcWUySVZmS0dOK3QxR0FpcWRaamRmeC9jNnRWWndjajBEZ09jUU1SQUMKSFJRWVBFaE5MNzBSSThBL01XeHhJVFo5QThNYzh0dFQwMk55aXo1VThpalFOMlZkazdwcVJDVWVHUk5UOWtVdQprbElEb1ltN3dLZG1TWnhPbEF4Skx5bkZwcnBSSzNSeVZ5a3QxeTJvandxOW5hSmpyUG1nM1ZBYXdUakZSbDN0CnQ2NHkyUlVqdHdlK3lqdUZLN3l5NkdwRnoySkFIVDYzblpZdHE5Y0F3NFJENjhJN0tGY3NZbGpLdHFwS1hoOEMKeGExQjRDVjhNclV3RnRPcnBxQ2xuTFBZWXNuZDhlM2xPM29oY1NEaTVJMUQ1Vmd5QkZVL05XcGdpMW1hNEt5WQowQUZ0QW9JQkFGZ1h0ZWM2VE1EVGVpRDFXQzRFK3E5aHNKZHBSamFwTGJqOGlTdFVyZVNmL2xIcFQrb1dYdUt3CnJnS2d6bm8vVjNxeEdKaFBWaFJJUW1Kb3U2M01LY1hxWXVwSlkxRTdjMmVhbU84SkpPZlpNTFFrWlN1MWlxSmIKZ3JITCt6YVAvTjRqVmkrWTJqbG81OEloYzBLNzVtak9rYjVBZ2ExOFhySnBlYlRHbFdnWFlxY05xUmZzbWhVago3VmMxQk9vVGwwb3pPU21JRmpyQUp3R0pNZjFuQzBuODI5Mks2WERyN0tDbDJXazN2OC9oVzNpRzJ6cW55aFBHCkl3czY0L0NLYU03OTdIc0R1ZXlBTU5vUVJXUHk5d2I3YXZqZlI2TDNGOWczS2l6c1pVbjFtUWcwc0JsQVRTU2QKVEN6SGxtdjZqQVFqY0RxVzdxQ3I0SHRFTXJBNjJGWT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

    - apiVersion: goharbor.io/v1beta1
      kind: HarborCluster
      metadata:
        name: harborcluster
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      spec:
        version: 2.5.0
        logLevel: info
        imageSource:
          repository: ghcr.io/goharbor
        harborAdminPasswordRef: admin-core-secret
        externalURL: https://${var.host}.${var.domain}
        expose:
          core:
            ingress:
              host: ${var.host}.${var.domain}
              ingressClassName: nginx
          notary:
            ingress:
              host: notary.${var.domain}
              ingressClassName: nginx
            tls:
              certificateRef: sample-public-certificate
        portal: {}
        registry:
          metrics:
            enabled: true
        core:
          tokenIssuer:
            name: selfsigned-issuer
            kind: Issuer
          metrics:
            enabled: true
        exporter: {}
        database:
          kind: PostgreSQL
          spec:
            postgresql:
              username: postsql # Required
              passwordRef: psqlSecret # Optional
              hosts:
                - host: psql # Required
                  port: 5432 # Optional
        storage:
          kind: "S3"
          spec:
            s3:
              accesskey: ak # Optional
              secretkeyRef: "minio-access-secret"
        cache: # Optional
          kind: "Redis"
          spec:
            redis:
              host: redis # Required
              port: 6347 # Required
              sentinelMasterSet: sentinel # Optional
              passwordRef: pwdSecret # Optional
              certificateRef: cert # Optional
    - apiVersion: goharbor.io/v1beta1
      kind: HarborConfiguration
      metadata:
        name: gsuite-config
        namespace: ${kubernetes_namespace.ns.metadata.0.name}
      spec:
        # your harbor configuration
        configuration:
          auth_mode: oidc
          oidc_client_secret: secret-sample
          oidc_name: "google"
          oidc_endpoint: "https://auth.google.com"
          oidc_scope: "openid,offline_access"
          oidc_verify_cert: false
          oidc_auto_onboard: true
        harborClusterRef: harborcluster
        EOF
  ]
}

resource "helm_release" "secrets" {
  for_each      = toset(var.secrets)
  wait          = true
  wait_for_jobs = true
  name          = each.key
  repository    = "https://dysnix.github.io/charts"
  chart         = "raw"
  version       = "0.3.1"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  values = [
    <<-EOF
    resources:
    - apiVersion: secrets.hashicorp.com/v1beta1
      kind: VaultStaticSecret
      metadata:
        namespace: ${var.namespace}
        name: ${each.key}
      spec:
        mount: "kvv2"
        type: kv-v2
        path: ${each.key}
        refreshAfter: 60s
        destination:
          create: true
          name: ${each.key}
          EOF
  ]
}

resource "helm_release" "minio-tenant" {
  depends_on = [helm_release.secrets]
  name       = "minio-tenant"
  repository = "https://operator.min.io/"
  chart      = "tenant"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  values = [templatefile("${path.module}/minio-tenant-values.yaml.tpl", {
    existing-secret = "minio-access-secret"
  })]
}

