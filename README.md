# Learn-vault-secrets-operator GitHub repo

This repo is a companion to [Static secrets with the Vault Secrets Operator on Kubernetes](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator) found on the [HashiCorp developer](https://developer.hashicorp.com/) site.

# Setup Vault

#### Install Vault if not already available:

helm repo add hashicorp https://helm.releases.hashicorp.com

helm repo update

helm search repo hashicorp/vault

helm install vault hashicorp/vault -n vault --create-namespace --values vault/vault-values.yaml

#### Wait a few minutes for the Pod to switch to Running status

### Create secrets in Vault for the demonstration

Copy bash scripts to Pod

kubectl cp ./static-secrets.sh vault/vault-0:/tmp/static-secrets.sh 

kubectl cp ./static-secrets.sh vault/vault-0:/tmp/dynamic-secrets.sh

Execute static bash script

kubectl exec --stdin=true --tty=true vault-0 -n vault -- /tmp/static-secrets.sh


# Install VSO 

helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault/vault-operator-values.yaml

## Deploy demo app

#### Create a namespace

kubectl create ns app

### Set up Kubernetes authentication for the secret

kubectl apply -f vault/vault-auth-static.yaml

#### Create secrets named secretkv and serverkv in the app ns

kubectl apply -f vault/static-secret.yaml
kubectl apply -f vault/another-static-secret.yaml

Spin-up a Pod to consume the secrets

kubectl apply -f envar-demo-.yaml

After a minute or so, peek inside the logs and you should see the values of the mapped environment variables
kubectl logs -f envar-demo

### Rotate the secret.  This can be done in the Vault console or the CLI as below.

kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh

vault kv put kvv2/webapp/config username="static-user2" password="static-password2"

#### Delete the pod envar-demo and recreate to see the newly rotated value

kubectl delete pod envar-demo --now
kubectl apply -f envar-demo.yaml

# Dynamic Secrets

#### Spin-up a Postgres POD

kubectl create ns postgres

helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install postgres bitnami/postgresql --namespace postgres --set auth.audit.logConnections=true  --set auth.postgresPassword=secret-pass

#### Execute dynamic bash script

kubectl exec --stdin=true --tty=true vault-0 -n vault -- /tmp/dynamic-secret.sh

#### Create the demo app

kubectl create ns demo-ns

kubectl apply -f dynamic-secrets/.

#### Observe the secrets via K9S


