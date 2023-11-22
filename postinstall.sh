#!/bin/sh

# Post installer for nodes
# (c) Chris Pinnock, 2023
# Ming Vase license - if it breaks, you get to keep the pieces. 
# No warranty whatsoever.

OS=debian-11
VER=18.1
V=18.1-1

URL=https://pkgbeta.tzinit.org/${OS}
ARCH=amd64
OCTEZBASE=octez

# Network - various options
#
#NET=mainnet
#NET=ghostnet
NET=nairobinet

# Mode & snapshot URL
#MODE=full

MODE=rolling
SNAPSHOT_URL=https://snapshots.eu.tzinit.org/${NET}/${MODE}


NETWORKURL=${NET}
if [ "$NET" != "mainnet" ] && [ "$NET" != "ghostnet" ]; then
    NETWORKURL=https://teztnets.xyz/${NET}
fi

# Update the package repository and upgrade the OS
#
apt-get update
apt-get upgrade -y

# Get and install packages
#
for pkg in client node; do
    fullpkg=${OCTEZBASE}-${pkg}_${V}_${ARCH}.deb
    wget -qq ${URL}/${fullpkg}
    apt-get install -y ./${fullpkg}
    rm -f ${fullpkg}
done

# Basic Configuration on the Octez node using network, history
# local RPC service and an open gossip port
#
su - tezos -c "octez-node config init --data-dir /var/tezos/node \
			--network=${NETWORKURL} \
			--history-mode=${MODE} \
			--rpc-addr='127.0.0.1:8732' \
		            --net-addr='[::]:9732'"

# Download the snapshot and import it
#
wget -qq ${SNAPSHOT_URL} -O /var/tezos/__snapshot
su - tezos -c "octez-node snapshot import /var/tezos/__snapshot --data-dir /var/tezos/node"
rm -f /var/tezos/__snapshot

# Enable services for next boot
#
systemctl enable octez-node

# Shutdown and reboot to pick up any new kernels
# Octez will start on boot
#
echo "===> Sleeping for reboot"
sleep 15
shutdown -r +1 &
