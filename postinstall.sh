#!/bin/sh

# Post installer for nodes
# (c) Chris Pinnock, 2023
# Ming Vase license - if it breaks, you get to keep the pieces. 
# No warranty whatsoever.

OS=deb11
VER=17.0-rc1
V=17.0rc1-1

URL=https://tz.fawlty.net/${OS}/${VER}
ARCH=amd64
OCTEZBASE=octez-${OS}-unoff

# Network
#
NET=mainnet
NETWORKURL=mainnet

#NET=narobinet
#NETWORKURL=https://teztnets.xyz/${NET}

# Mode
#
MODE=rolling
SNAPSHOT_URL=https://${NET}.xtz-shots.io/${MODE}

#MODE=full
#SNAPSHOT_URL="https://snapshots.tezos.marigold.dev/api/${NET}/full"

# Upgrade OS
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

# Configuration
#
su - tezos -c "octez-node config init --data-dir /var/tezos/node \
			--network=${NETWORKURL} \
			--history-mode=${MODE} \
			--rpc-addr='127.0.0.1:8732' \
		            --net-addr='[::]:9732'"

# Snapshot
#
wget -qq ${SNAPSHOT_URL} -O /var/tezos/__snapshot
su - tezos -c "octez-node snapshot import /var/tezos/__snapshot --data-dir /var/tezos/node"
rm -f /var/tezos/__snapshot

# Enable services
systemctl enable octez-node
systemctl start octez-node

## Wait for bootstrap
#
while [ 1 = 1 ]; do
    octez-client bootstrapped
    if [ $? != "0" ]; then
        echo "Waiting for bootstrap..."
        sleep 30
    else
        break
    fi

done


# Shutdown and reboot to pick up all updates
#
echo "===> Sleeping for reboot"
sleep 30
shutdown -r now
