
# Outline

Can of course use dockers or

Use v17.0. 

1. Install the gcloud tools on your local machine

The documentation is here.
https://cloud.google.com/sdk/gcloud/reference

Alternatively you can use a cloud shell console. Log in to GCP and click the cloud shell icon.

2. Add a project to GCP, in the console or:
gcloud projects create your-project-name --name="My first GCP Tezos node"
gcloud config set project your-project-nameid

chris_pinnock@cloudshell:~ (my-even-newer-project-delete)$ gcloud beta billing accounts list
ACCOUNT_ID: AAA
NAME: TF Old Master - dont use
OPEN: True
MASTER_ACCOUNT_ID: 

ACCOUNT_ID: CCC
NAME: Tezos Foundation Invoicing Master account
OPEN: True
MASTER_ACCOUNT_ID: 

ACCOUNT_ID: BBB
NAME: TF - Old - Don't use
OPEN: True
MASTER_ACCOUNT_ID: 

gcloud beta billing projects link your-project-nameid --billing-account 01B9ED-1CF9CC-5BF3

3. Enable Compute Engine, in the console or:
gcloud services enable compute.googleapis.com 

3

4. Get the service account info (in the console go to IAM and choose the default Compute Engine service account). Or:

$ gcloud iam service-accounts list 

DISPLAY NAME                            EMAIL                                               DISABLED
Compute Engine default service account	626877545470-compute@developer.gserviceaccount.com  False

DISPLAY NAME: Compute Engine default service account
EMAIL: 817181145262-compute@developer.gserviceaccount.com
DISABLED: False

Create a service account for the project. 

5. Edit the setup script to have the correct PROJECT name etc

6. Run setup.sh (upload it to the Cloud Shell if you need to)

Bin this and make it part of the article

6. Log into the machine and watch the progress:
gcloud compute ssh --zone europe-west6-a my-tezos-node
tail -f /tmp/install.log
