---
title: "Setting up a Tezos node on GCP"
author: "Chris Pinnock"
date: "28 May 2023"
titlepage: false
toc-own-page: true
colorlinks: true
listings: true
listings-disable-line-numbers: true
---

# Introduction

[Tezos](https://tezos.com) is a proof-of-stake blockchain and anyone can run a node on it to participate in the network. Recently I have been working on the [Google Cloud Platform (GCP)](https://cloud.google.com/). I needed to bring up some Tezos nodes quickly. There are many ways to do this. You can use docker images, Google Compute images, software packages or a scripted installation. You can also use tools like [Terraform](https://www.terraform.io/) to bring up infrastructure, but on this occasion I wanted to get some hands-on experience with the command line ```gcloud``` tool. 

One of the things that I like about GCP is that it is possible to interact with it on the command line. Many screens in the online console offer the ability to output the equivalent command line code at the push of a button. This makes it incredibly easy to write provisioning scripts for small projects. ```gcloud``` runs natively on Linux, Macs and Windows, and allows you to interactively provision services by typing commands and by extension allows you to write scripts to provision services very quickly.

In this article we will install a Tezos node completely from the command line. We will use the Google Cloud shell in the browser, but you can follow along with ```gcloud``` installed on your machine if you want. You will need a GCP billing account either with billing credits or a payment method defined.

# Outline

XXX

# Installation

1. Login to the [Google Cloud Platform GUI](https://console.cloud.google.com/) with your Google account. If this is your first login, you may need to activate the account and set it up. You may also be eligible for credits.

2. Start the Cloud Shell. The Cloud Shell runs in a web browser. You can start it by clicking the Cloud Shell button at the top right of the console.

![Starting Cloud Shell](img/CloudShell.png)

Alternatively, you can install ```gcloud``` on your machine and run the commands there. You can download it from https://cloud.google.com/sdk/docs/install. Follow the installation instructions and once installed, use ```gcloud init`` to setup the software for your GCP account.

The documentation for ```gcloud``` can be found here: https://cloud.google.com/sdk/gcloud/reference and there is a cheat cheat here: https://cloud.google.com/sdk/docs/cheatsheet


2. Add a new project to GCP, then set the default so that future commands run on the project.

```
gcloud projects create my-tezos-project-chris --name="My first GCP Tezos node"
gcloud config set project my-tezos-project-chris
```

![Cloud Shell](img/CloudShellInAction.png)

3. You can add the project to your billing account using ```gcloud``` as follows. At the time of writing, the billing commands are still in beta. GCP allows users to test *alpha* and *beta* versions by adding the words 'alpha' or 'beta' after ```gcloud```. If you are working on a corporate account, you may need to as your GCP administrator.

You can list your billing accounts as follows:

```
$ gcloud beta billing accounts list
ACCOUNT_ID: DEADBE-EDEAD-BEEF12
NAME: Acme Widgets Main Account
OPEN: True
MASTER_ACCOUNT_ID: 
```

Then attach your account as follows:

```
gcloud beta billing projects link my-tezos-project-chris \
    --billing-account DEADBE-EDEAD-BEEF12
```

3. We want to run VMs so we need to enable Compute Engine:

```
gcloud services enable compute.googleapis.com 
```

4. Get the default compute service account info in order to provision the VM. 

```
$ gcloud iam service-accounts list 

DISPLAY NAME: Compute Engine default service account
EMAIL: 123456789123-compute@developer.gserviceaccount.com
DISABLED: False
```

Alternatively you can create a service account specifically using a name over 6 characters. In this case, the service account will be ```tezos@my-tezos-project-chris.iam.gserviceaccount.com```.

```
$ gcloud iam service-accounts create tezosaccount \
        --display-name="Tezos Service Account"
$ gcloud iam service-accounts list 
DISPLAY NAME: Tezos Service Account
EMAIL: tezosaccount@my-tezos-project-chris.iam.gserviceaccount.com
DISABLED: False

DISPLAY NAME: Compute Engine default service account
EMAIL: 123456789123-compute@developer.gserviceaccount.com
DISABLED: False
```

5. Bring up a virtual machine. We are going to use *europe-west6-a* in Zürich, but you can choose any zone you want. We will use the *e2-standard-2* instance. It has 8GB of RAM and it is sufficient to run a node. We will be using Debian v11 Linux. Also note that we will use a disc of 80GB. This is fine for a rolling node. Make sure that you substitute the service account with the correct one and the project ID.

```
gcloud compute instances create my-tezos-node \
	--zone=europe-west6-a \
	--machine-type=e2-standard-2 \
    --service-account=123456789123-compute@developer.gserviceaccount.com \
    --create-disk=auto-delete=yes,boot=yes,device-name=my-tezos-node,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=80,type=projects/my-tezos-project-chris/zones/europe-west6-a/diskTypes/pd-balanced \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--scopes=https://www.googleapis.com/auth/cloud-platform \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any
```

Only the first four options *zone*, *machine-type*, *service-account* and *create-disk* need your attention. Please tune the options so that they are suitable for your purposes. If you are unsure here, you can always add an instance from the web console or click "Equivalent Code" to see the options.

![Setting up the VM in the Console](img/VM.png)

7. We have written a post installation script *postinstall.sh* to do the rest. The script is available for [download from Github](https://github.com/drchrispinnock/gcp-node-example/blob/main/postinstall.sh) (you can find the download link next to the Raw button).

 We could have given this script with some modification to the VM creation command above as an option ```--metadata-from-file=```, but it can take a long time to run. The GCP system expects a virtual machine to complete provisioning within 10 minutes which means it will be terminated by GCP. We will run it by hand.

First upload it to the Cloud Shell and then copy it to the VM.

![Upload a file](img/UploadFile.png)

We can copy the file to the VM using secure shell and then run it in the same way as follows:

```
gcloud compute scp --zone=europe-west6-a postinstall.sh my-tezos-node:/tmp
gcloud compute ssh --zone=europe-west6-a my-tezos-node \
         --command "nohup sudo sh /tmp/postinstall.sh"
```

If you have not used *scp* or *ssh* below, Google Cloud might ask you about generating a key for it. Just confirm that you do and enter a passphrase that you can remember when prompted:

```
WARNING: The private SSH key file for gcloud does not exist.
WARNING: The public SSH key file for gcloud does not exist.
WARNING: You do not have an SSH key for gcloud.
WARNING: SSH keygen will be executed to generate a key.
This tool needs to create the directory [/home/chris_pinnock/.ssh] before being able to generate SSH keys.

Do you want to continue (Y/n)?  
```

9. You will see progress in the shell, but let's examine what *postinstall.sh* is doing.

The first piece of code is just preamble, setting up various variables and settings. We will be joining the *nairobinet* test network, with a *rolling* node and by the end of this segment, the network URL will be set to *https://teztnets.xyz/nairobinet* and the snapshot URL will be set to *https://nairobinet.xtz-shots.io/rolling*.

Of course, if you want to run a node on a different network you can change the script before using it.

```
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

# Network - various options
#
#NET=mainnet
#NET=ghostnet
#NET=mumbainet
NET=nairobinet

# Mode & snapshot URL
#MODE=full
#SNAPSHOT_URL="https://snapshots.tezos.marigold.dev/api/${NET}/full"

MODE=rolling
SNAPSHOT_URL=https://${NET}.xtz-shots.io/${MODE}

NETWORKURL=${NET}
if [ "$NET" != "mainnet" ] && [ "$NET" != "ghostnet" ]; then
    NETWORKURL=https://teztnets.xyz/${NET}
fi
```

Then we update the operating system using the standard Debian packaging tools.

```
# Update the package repository and upgrade the OS
#
apt-get update
apt-get upgrade -y
```

We then fetch and download packages for Octez. The script is setup to download them from my website https://tz.fawlty.net/.

```
# Get and install packages
#
for pkg in client node; do
    fullpkg=${OCTEZBASE}-${pkg}_${V}_${ARCH}.deb
    wget -qq ${URL}/${fullpkg}
    apt-get install -y ./${fullpkg}
    rm -f ${fullpkg}
done
```

Once the packages have downloaded, we setup a basic configuration for Octez using the Network URL and the history mode. We also allow local remote procedure calls and listen on 9732 for the Tezos gossip network.

```
# Basic Configuration on the Octez node using network, history
# local RPC service and an open gossip port
#
su - tezos -c "octez-node config init --data-dir /var/tezos/node \
			--network=${NETWORKURL} \
			--history-mode=${MODE} \
			--rpc-addr='127.0.0.1:8732' \
		            --net-addr='[::]:9732'"
```

Then we download a snapshot and import it. Doing this allows us to quickly catchup with the network data.

```
# Download the snapshot and import it
#
wget -qq ${SNAPSHOT_URL} -O /var/tezos/__snapshot
su - tezos -c "octez-node snapshot import /var/tezos/__snapshot --data-dir /var/tezos/node"
rm -f /var/tezos/__snapshot
```

We then enable the Octez node service and reboot. When the system has rebooted, it will start Octez and synchronise with the network.

```
# Enable services for next boot
#
systemctl enable octez-node

# Shutdown and reboot to pick up any new kernels
# Octez will start on boot
#
echo "===> Sleeping for reboot"
sleep 15
shutdown -r now
```


10. When the system has rebooted, you can log in and check the health. The packages we have used run the Octez software under a dedicated user called *tezos*. Here we switched to the user and checked the status with ```octez-client bootstrapped```. Additionally you can look at the log files in ```/var/log/tezos/node.log```.


```
$ gcloud compute ssh --zone=europe-west6-a my-tezos-node
Linux my-tezos-node 5.10.0-22-cloud-amd64 #1 SMP Debian 5.10.178-3 (2023-04-22) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
chris_pinnock@my-tezos-node:~$ sudo su - tezos
tezos@my-tezos-node:~$ octez-client bootstrapped
Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Waiting for the node to be bootstrapped...
Current head: BLbZNKRZhrpT (timestamp: 2023-05-27T05:27:50.000-00:00, validation: 2023-05-27T18:04:01.014-00:00)
Current head: BMFsRWxTZCGq (timestamp: 2023-05-27T05:27:58.000-00:00, validation: 2023-05-27T18:04:01.049-00:00)
Current head: BL7aSqHixQSf (timestamp: 2023-05-27T05:28:06.000-00:00, validation: 2023-05-27T18:04:01.081-00:00)
Current head: BMWtU2ti85Ay (timestamp: 2023-05-27T05:28:14.000-00:00, validation: 2023-05-27T18:04:01.115-00:00)
...
...
Current head: BMYPJrU3n39d (timestamp: 2023-05-27T18:06:54.000-00:00, validation: 2023-05-27T18:07:12.389-00:00)
Current head: BMajkArZFeRh (timestamp: 2023-05-27T18:07:02.000-00:00, validation: 2023-05-27T18:07:12.423-00:00)
Current head: BLGkdx644FPs (timestamp: 2023-05-27T18:07:10.000-00:00, validation: 2023-05-27T18:07:12.459-00:00)
Node is bootstrapped.
```

# After

XXX Delete instanced

# Exercises

1. Find our how to create a project in GCP using ```gcloud```.

2. Write a shell script that:

- creates a new GCP project
- adds it to a billing account (optional)
- enables the GCP Compute Engine
- creates a service account
- provisions a VM using the service account
- copies the postinstall script to the VM and then runs it

Hint:
- If your project is called *tezos-project* and you create a service account with short name *serviceacct*, the service account will be *serviceacct@tezos-project.iam.gserviceaccount.com*
- You will need to consider the project name and service account name in the ```gcloud``` command - use variables.

3. Modify the postinstall script so that the Tezos node runs on mainnet

4. Modify your script from 2 to setup 3 nodes - one in USA, one in Europe and one in Japan.

Hints:
- Pick three zones from the GCP list
- Use a for loop to iterate through the zones
- Modify the instance name, zone and disk clause in the glcoud command by using the loop variable
