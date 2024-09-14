# Apps

Applications that are deployed to the cluster and managed by Flux.

## Cert Manager

Setting Up:

1. Get api token from https://dash.cloudflare.com/profile/api-tokens and store it in a secret, using sops.

`kubectl create secret generic cloudflare-api-token \
--from-literal api-token='token' -n cert-manager  --dry-run=client -o yaml`

1. Go to /controllers/env/cert-manager/certs-kustomization.yaml and update the dnsNames to match your domain

## Keycloak

Setting Up:

1. Create app user and superuser secrets for postgres:

`kubectl create secret generic keycloak-postgres-user \
--from-literal=username='username' \
--from-literal=password='password' -n keycloak --type kubernetes.io/basic-auth --dry-run=client -o yaml`
