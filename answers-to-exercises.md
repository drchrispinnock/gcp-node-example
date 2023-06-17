# Answers to the exercises

1. Find our how to create a project in GCP using ```gcloud```.

You can find this out from the gcloud dev guide. XXX

```
gcloud projects create "my-own-gcp-project"
```

This can be added to a billing account as follows:

```
gcloud beta billing projects link "my-own-gcp-project" \
        --billing-account DEADBE-EDEAD-BEEF12
```

2. Write a shell script that:

- creates a new GCP project
- adds it to a billing account (optional)
- enables the GCP Compute Engine
- creates a service account
- provisions a VM using the service account
- copies the postinstall script to the VM and then runs it

See *exercise2.sh*.

3. Modify the postinstall script so that the Tezos node runs on mainnet

Change ```NET=nairobinet``` to ```NET=mainnet``` in *postinstall.sh*.

4. Modify your script from 2 to setup 3 nodes - one in USA, one in Europe and one in Japan.

See *exercise4.sh*.