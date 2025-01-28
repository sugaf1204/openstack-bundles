#!/bin/bash -eux

sudo snap install openstackclients

wget -O ~/openrc https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/_downloads/c894c4911b9572f0b5f86bdfc5d12d8e/openrc

source ~/openrc

mkdir -p ~/cloud-images

# if [ ! -f ~/cloud-images/jammy.img ]; then
#    wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
#       -O ~/cloud-images/jammy.img
# fi

# openstack image create --public --container-format bare \
#    --disk-format qcow2 --file ~/cloud-images/jammy.img \
#    jammy

openstack flavor create --vcpu 1 --ram 1024 --ephemeral 10 m1.tiny

openstack flavor create --vcpu 1 --ram 2048 --ephemeral 30 m1.small

openstack flavor create --vcpu 2 --ram 4096 --ephemeral 60 m1.medium

openstack flavor create --vcpu 4 --ram 8192 --ephemeral 120 m1.large

openstack flavor create --vcpu 8 --ram 16384 --ephemeral 240 m1.xlarge


openstack network create --external --share \
   --provider-network-type flat --provider-physical-network physnet1 \
   ext_net
openstack subnet create --network ext_net --no-dhcp \
   --gateway 192.168.2.1 --subnet-range 192.168.2.0/24 \
   --allocation-pool start=192.168.2.100,end=192.168.2.150 \
   ext_subnet

openstack network create --internal user1_net
openstack subnet create --network user1_net --dns-nameserver 192.168.2.254 \
   --subnet-range 10.146.0/24 \
   --allocation-pool start=10.146.0.10,end=10.146.0.99 \
   user1_subnet

openstack router create user1_router
openstack router add subnet user1_router user1_subnet
openstack router set user1_router --external-gateway ext_net

export FCOS_VERSION="35.20220116.3.0"
wget -O ~/cloud-images/fedora.qcow2.xz https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-openstack.x86_64.qcow2.xz
unxz ~/cloud-images/fedora.qcow2.xz

openstack image create \
   --disk-format qcow2 \
   --container-format bare \
   --file ~/cloud-images/fedora.qcow2 \
   --property os_distro='fedora-coreos' \
   fedora-coreos-latest
