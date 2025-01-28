#!/bin/bash -eux

set +x
until juju status | grep -E '^vault/0' | grep '192.168'; do sleep 10; done
set -x

## Vault: Authorize Charm
VAULT_IP=`juju status | grep -E '^vault/0' | awk '{print $5}'`
export VAULT_ADDR="http://$VAULT_IP:8200"

set +x
until curl $VAULT_ADDR; do sleep 10; done
until juju status | grep 'vault-mysql-router/0' | grep 'active'; do sleep 10; done
set -x

until vault operator init -key-shares=5 -key-threshold=3 > vault-init.txt; do sleep 10; done
cat vault-init.txt | grep -E '^Unseal Key' | cut -d' ' -f4 | head -n3 | xargs -I{} vault operator unseal {} | tee vault-unseal.txt
export VAULT_TOKEN=`cat vault-init.txt | grep -E '^Initial Root Token' | cut -d' ' -f4`

until vault token create -ttl=10m > vault-token.txt; do sleep 10; done
cat vault-token.txt | grep -E '^token ' | awk '{print $2}' | xargs -I{} juju run vault/0 authorize-charm token={}

# Vault: Generate CA Cert
juju run vault/leader generate-root-ca | tee vault-ca.txt
