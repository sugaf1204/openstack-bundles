#!/bin/bash

sudo snap install juju vault openstackclients

juju add-cloud --client -f maas-cloud.yaml maas
juju add-credential --client -f maas-creds.yaml maas
juju bootstrap --bootstrap-base=ubuntu@22.04 --bootstrap-constraints arch=amd64 --constraints tags=juju-controller maas maas-controller
juju add-model -c maas-controller --config default-series=jammy openstack
juju deploy ./os.yaml

./vault.sh

