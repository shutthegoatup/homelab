# homelab

This is my homelab configuration.  

It's a bunch of pet services in an on-prem KIND kubernetes cluster configured with terraform acting as an SDLC tooling cluster.  I use this to bootstrap full automation for other projects, but as I'm the only user, services tend to have fairly liberal permissions, i.e. cluster-admin.

This repo should serve as an educational example of how you bootstrap the world when you're starting from scratch.

## Configured services

The following services should: 

- cleanly install
- avoid / not expose static secrets
- use single sign-on ( where applicaible )

They may have:

- a HA configuration 
- service monitors
- testing suite

### terraform/01_init_secrets

This stage loads secrets from external services into k8s.

These are:

- Google OIDC secrets for Workspace SSO.
- Github app secrets for various services.
- Cloudflare for DNS ( letsencrypt and external-dns )

I note the following concessions:

- We wanted to avoid static secrets.  You can of course have vault mint tokens for these services, but in order to have a vault, you need to bootstrap it.  The trick is to contain these secrets so they're shared with few people and easy to rotate.
- "From scatch" but I just dropped 3 cloud services.  Pragmatism.  If you do want to go full on-prem, I'll drop some solid alternatives.  More likely you'll need a strategy to connect providers.  

### terraform/02_network

Services required to bootstrap the cluster to serve traffic.

- cilium
- ingress-nginx
- metallb
- cert-manager
- vault

### terraform/03_observability

Services required to observe, monitor & autoscale other services.

- kube-prometheus 
- metrics-server
- vertical-pod-autoscaler
- parca
- vault-config
- vault-secrets-operator

There's a bug with the vault provider where you can't configure and use it in the same run.

### terraform/04_cicd

Services required to bootstrap the cluster to serve traffic.

- argo (cd, events, rollouts)
- atlantis
- github actions runner controller 
- harbor
- operators ( postgres, redis, minio )

We can now automatically run tests, deploy ephemeral environments, and promote production ready services.  

### terraform/05_servies

Random services of doom.  

If I want to test something, I might put it here.
