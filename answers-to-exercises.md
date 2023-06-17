# Answers to the exercises

Resources can be found at [https://github.com/drchrispinnock/gcp-node-example](https://github.com/drchrispinnock/gcp-node-example).

1. Find out how to stop a VM in GCP using ```gcloud```.

For this refer to the ```gcloud``` documentation:
- [Gcloud dev guide](https://cloud.google.com/sdk/gcloud/reference)
- [Gcloud cheat sheet](https://cloud.google.com/sdk/docs/cheatsheet)

For instance *my-instance* in zone europe-west6-a use the following command:
```
gcloud compute instances stop my-instance --zone=europe-west6-a
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

5. Although we set up our original server to allow connections on 9732 for the Tezos Gossip network, the GCP firewall will prevent the connections. How do you add a rule to allow it?

This is another question where you need to read the document but it will be harder for a beginner. Here is the command:

```
gcloud compute --project=your-project-id firewall-rules create \
        tezos-gossip-port --direction=INGRESS --priority=1000 \
        --network=default --action=ALLOW --rules=tcp:9732 \
        --source-ranges=0.0.0.0/0