#!/bin/sh

PROJECTID=your-project-id
BILLINGACCT=DEADBE-EDEAD-BEEF12

SERVICEACCT="tezos-project"
SERVICE_ACCOUNT="${SERVICEACCT}@${PROJECTID}.developer.gserviceaccount.com"

NAME=my-tezos-node

MACHINE=e2-standard-2 # 8GB of RAM
DEBIAN_BUILD=debian-11-bullseye-v20230509
SIZE=80

# Create a project
#
gcloud projects create ${PROJECTID}
gcloud beta billing projects link ${PROJECTID} \
        --billing-account ${BILLINGACCT}

# Enable Compute Engine
#
gcloud services enable compute.googleapis.com --project=${PROJECT}

# Create the service account
#
gcloud --project=${PROJECT} \
        iam service-accounts create ${SERVICEACCT} \
        --display-name="My Tezos Project Service Account"

# This command was given to us by using "Equivalent Command Line" on the Google
# Web Console for Compute Engine
#

gcloud compute instances create my-tezos-node \
	--project=${PROJECTID} \
	--zone=europe-west6-a \
	--machine-type=${MACHINE} \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--service-account=${SERVICE_ACCOUNT} \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--create-disk=auto-delete=yes,boot=yes,device-name=my-tezos-node,image=projects/debian-cloud/global/images/${DEBIAN_BUILD},mode=rw,size=${SIZE},type=projects/${PROJECTID}/zones/europe-west6-a/diskTypes/pd-balanced \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any

# Wait a little while for the instance to be ready
#
sleep 30    

# Copy the script and execute it
#       
gcloud compute scp --project=${PROJECTID} --zone=europe-west6-a postinstall.sh my-tezos-node:/tmp
gcloud compute ssh --project=${PROJECTID} --zone=europe-west6-a my-tezos-node --command "nohup sudo sh /tmp/postinstall.sh > /tmp/install.log 2>&1 &"

