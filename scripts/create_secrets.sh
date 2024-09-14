#!/bin/bash

# EXPECTED ENVIRONMENT VARIABLES:
# ENVIRONMENT
# CF_API_TOKEN: Cloudflare API token
# S3_ACCESS_KEY_ID
# S3_SECRET_ACCESS_KEY
# KEYCLOAK_POSTGRES_APP_USERNAME
# KEYCLOAK_POSTGRES_APP_PASSWORD
# KEYCLOAK_POSTGRES_SUPERUSER_USERNAME
# KEYCLOAK_POSTGRES_SUPERUSER_PASSWORD

# Load environment variables from .env file
if [ -f .env ]; then
  # Export all variables defined in .env
  export $(grep -v '^#' .env | xargs)
else
  echo "ERROR: .env file not found."
  exit 1
fi

# Array of expected environment variables
expectedSecrets=(
  ENVIRONMENT
  CF_API_TOKEN
  S3_ACCESS_KEY_ID
  S3_SECRET_ACCESS_KEY
  KEYCLOAK_POSTGRES_APP_USERNAME
  KEYCLOAK_POSTGRES_APP_PASSWORD
  KEYCLOAK_POSTGRES_SUPERUSER_USERNAME
  KEYCLOAK_POSTGRES_SUPERUSER_PASSWORD
)

# Verify that all expected variables are set
for secret in "${expectedSecrets[@]}"; do
  if [ -z "${!secret}" ]; then
    echo "ERROR: Environment variable $secret is not set in .env file."
    exit 1
  fi
done

# Create secrets and output them to corresponding YAML files in the environment directory

cert_manager_directory="controllers/$ENVIRONMENT/cert-manager"

## Create Cloudflare API token secret
kubectl create secret generic cloudflare-api-token \
  --from-literal=api-token="$CF_API_TOKEN" \
  -n cert-manager --dry-run=client -o yaml > "$cert_manager_directory/cloudflare-api-token.sops.yaml"

# Encrypt the secret using sops
sops -i -e "$cert_manager_directory/cloudflare-api-token.sops.yaml"

keycloak_postgres_directory="apps/$ENVIRONMENT/keycloak/postgres"

## Create S3 credentials secret
kubectl create secret generic s3-credentials \
  --from-literal=access-key-id="$S3_ACCESS_KEY_ID" \
  --from-literal=secret-access-key="$S3_SECRET_ACCESS_KEY" \
  -n keycloak --dry-run=client -o yaml > "$keycloak_postgres_directory/s3-credentials.sops.yaml"

# Encrypt the secret using sops
sops -i -e "$keycloak_postgres_directory/s3-credentials.sops.yaml"


## Create Keycloak Postgres App User secret
kubectl create secret generic keycloak-postgres-user \
  --from-literal=username="$KEYCLOAK_POSTGRES_APP_USERNAME" \
  --from-literal=password="$KEYCLOAK_POSTGRES_APP_PASSWORD" \
  -n keycloak --type kubernetes.io/basic-auth --dry-run=client -o yaml > "$keycloak_postgres_directory/keycloak-postgres-user.sops.yaml"

# Encrypt the secret using sops
sops -i -e "$keycloak_postgres_directory/keycloak-postgres-user.sops.yaml"

## Create Keycloak Postgres Superuser secret
kubectl create secret generic keycloak-postgres-superuser \
  --from-literal=username="$KEYCLOAK_POSTGRES_SUPERUSER_USERNAME" \
  --from-literal=password="$KEYCLOAK_POSTGRES_SUPERUSER_PASSWORD" \
  -n keycloak --type kubernetes.io/basic-auth --dry-run=client -o yaml > "$keycloak_postgres_directory/keycloak-postgres-superuser.sops.yaml"

# Encrypt the secret using sops
sops -i -e "$keycloak_postgres_directory/keycloak-postgres-superuser.sops.yaml"

echo "Secrets have been generated and encrypted in their corresponding directories"