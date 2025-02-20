#!/bin/sh

set -xe


# export VAULT_NAMESPACE=us-west-org
vault auth enable -path demo-auth-mount kubernetes
sleep 10

vault write auth/demo-auth-mount/config \
		kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault secrets enable -path=kvv2 kv-v2
sleep 10

vault policy write dev - <<EOF
path "kvv2/data/webapp/*" {
   capabilities = ["read", "list", "subscribe"]
   subscribe_event_types = ["kv*"]
}
path "sys/events/subscribe/kv*" {
   capabilities = ["read"]
}
EOF

vault write auth/demo-auth-mount/role/role1 \
   bound_service_account_names=demo-static-app bound_service_account_namespaces=app policies=dev token_period=2m audience=vault
sleep 10

vault kv put kvv2/webapp/config username="static-user1" password="static-password1"
vault kv put kvv2/webapp/config2 servername="server1" password="secretpassword1"
vault kv put kvv2/webapp/config3 ipaddress="10.0.0.1" subnet="255.255.255.0"


