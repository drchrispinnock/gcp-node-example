#!/bin/sh

# Create a node
#

DC="europe-west6"
ZONE=${DC}-a
PROJECTID=your-project-id
SERVICE_ACCOUNT="youraccountdetail-compute@developer.gserviceaccount.com"
NAME=my-tezos-node

MACHINE=e2-standard-4 # 16GB of RAM
DEBIAN_BUILD=debian-11-bullseye-v20230509
SIZE=200

MODE=rolling

gcloud compute instances create ${NAME} \
	--project=${PROJECTID} \
	--zone=${ZONE} \
	--machine-type=${MACHINE} \
        --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--service-account=${SERVICE_ACCOUNT} \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--create-disk=auto-delete=yes,boot=yes,device-name=${NODE},image=projects/debian-cloud/global/images/${DEBIAN_BUILD},mode=rw,size=${SIZE},type=projects/${PROJECTID}/zones/${ZONE}/diskTypes/pd-balanced \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any
        
sleep 30    
        
gcloud compute scp --project=${PROJECTID} --zone=${ZONE} postinstall.sh ${NAME}:/tmp
gcloud compute ssh --project=${PROJECTID} --zone=${ZONE} ${NAME} --command "nohup sudo sh /tmp/postinstall.sh > /tmp/install.log 2>&1 &"

