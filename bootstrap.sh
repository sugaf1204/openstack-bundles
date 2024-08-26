#!/bin/bash


# juju add-cloud --client -f maas-cloud.yaml maas-one
# juju add-credential --client -f maas-creds.yaml maas-one
# juju bootstrap --bootstrap-base=ubuntu@22.04 --bootstrap-constraints arch=amd64 --constraints tags=juju-controller maas-one maas-controller
# juju add-model -c maas-controller --config default-series=jammy openstack
# juju deploy ./development/openstack-base-jammy-yoga/bundle.yaml --overlay ./development/openstack-base-jammy-yoga/openstack-base-virt-overlay.yaml
