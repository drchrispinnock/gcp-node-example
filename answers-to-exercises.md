# Answers to the exercises

Resources can be found at [https://github.com/drchrispinnock/gcp-node-example](https://github.com/drchrispinnock/gcp-node-example).

1. Find our how to create a project in GCP using ```gcloud```.

For this refer to the ```gcloud``` documentation:
- [Gcloud dev guide](https://cloud.google.com/sdk/gcloud/reference)
- [Gcloud cheat sheet](https://cloud.google.com/sdk/docs/cheatsheet)


Create a project as follows:

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