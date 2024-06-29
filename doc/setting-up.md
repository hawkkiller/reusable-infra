# Setting up

In infrastructure nginx-ingress and cert-manager are deployed. The nginx-ingress is used to route the traffic to the correct service and cert-manager is used to automatically generate and renew the SSL certificates.

## Prerequisites

- Age and sops cli installed
- Flux cli installed
- Cloudflare API Token, obtain here https://dash.cloudflare.com/profile/api-tokens

## Sops

The secrets are encrypted using sops. The sops cli is used to encrypt and decrypt the secrets. The sops cli is installed using the following command:

```bash
brew install sops
```

Steps to configure sops:

1. Create an age key pair using the following command:

```bash
age-keygen -o sops.agekey
```

2. Put your private key in a safe place and add the public key to the repository to .sops.yaml file:

```yaml
creation_rules:
  - path_regex: .*.ya?ml
    encrypted_regex: ^(data|stringData)$
    age: <here>
```

3. Encrypt the secrets using the following command:

```bash
sops -e secrets.yaml > secrets.enc.yaml
```

4. Decrypt the secrets using the following command:

```bash
sops -d secrets.enc.yaml > secrets.yaml
```