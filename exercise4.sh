#!/bin/sh

PROJECTID=your-project-id
BILLINGACCT=DEADBE-EDEAD-BEEF12

SERVICEACCT="tezos-project"
SERVICE_ACCOUNT="${SERVICEACCT}@${PROJECTID}.developer.gserviceaccount.com"

NAME=my-tezos-node

MACHINE=e2-standard-2 # 8GB of RAM
DEBIAN_BUILD=debian-11-bullseye-v20230509
SIZE=80

# Three zones
#
ZONES="us-central1-b europe-west6-a asia-northeast1-a"

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



for ZONE in ${ZONES}; do

	INSTANCE="tezos-node-${ZONE}"

	gcloud compute instances create ${INSTANCE} \
		--project=${PROJECTID} \
		--zone=${ZONE} \
		--machine-type=${MACHINE} \
		--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
		--maintenance-policy=MIGRATE \
		--provisioning-model=STANDARD \
		--service-account=${SERVICE_ACCOUNT} \
		--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
		--create-disk=auto-delete=yes,boot=yes,device-name=${INSTANCE},image=projects/debian-cloud/global/images/${DEBIAN_BUILD},mode=rw,size=${SIZE},type=projects/${PROJECTID}/zones/${ZONE}/diskTypes/pd-balanced \
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
	gcloud compute scp --project=${PROJECTID} --zone=${ZONE} postinstall.sh ${INSTANCE}:/tmp
	gcloud compute ssh --project=${PROJECTID} --zone=${ZONE} ${INSTANCE} --command "nohup sudo sh /tmp/postinstall.sh > /tmp/install.log 2>&1 &"

done

