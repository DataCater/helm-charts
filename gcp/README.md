# datacater-helm-chart
Helm chart for deploying DataCater on Google Kubernetes Engine.

## Installation on GCP

Make sure to have cluster running with `WorkloadIdentity` and `ConfigConnector` enabled.
See
- https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall
- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity

### Before you begin
Make sure to have the following resources / APIs enabled in GCP:
- [ ] CloudSQL PostgresQL instance
- [ ] Database called `datacater`
- [ ] Kubernetes API enabled
- [ ] GCR API enabled

We recommend executing all commands from the root of this project and not from this sub-folder.
### Source your env file in the root directory with the GCLOUD Settings
```
$ source .env 
```

### Create cluster with `gcloud`, where above apis are enabled:
```
gcloud container clusters create $GCLOUD_CLUSTER \
--project $GCLOUD_PROJECT \
--release-channel regular \
--addons=ConfigConnector,HttpLoadBalancing \
--num-nodes=3 \
--max-nodes-per-pool=100 \
--node-locations=$GCLOUD_ZONE \
--region=$GCLOUD_REGION \
--machine-type=$GCLOUD_MACHINE_TYPE \
--workload-pool="$GCLOUD_PROJECT.svc.id.goog" \
--enable-stackdriver-kubernetes
```

### Configure kubectl and add nodes to cloud sql
```
gcloud container clusters get-credentials $GCLOUD_CLUSTER --region $GCLOUD_REGION --project $GCLOUD_PROJECT
```

### Create gcp service accounts, role bindings and generate key

```
gcloud iam service-accounts create $GCLOUD_CLUSTER-gcr-access \
    --description="GKE cluster storageadmin rights for push pull to GCR" \
    --display-name="$GCLOUD_CLUSTER-gcr-access"
```
```
gcloud projects add-iam-policy-binding $GCLOUD_PROJECT \
    --member="serviceAccount:$GCLOUD_CLUSTER-gcr-access@$GCLOUD_PROJECT.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
```
StorageAdmin is needed for the first push as Container Registry is backed by GCR.
See https://cloud.google.com/container-registry/docs/access-control#grant

Now we add the`artifactRegistry.writer` role to the same service account.
```
gcloud projects add-iam-policy-binding $GCLOUD_PROJECT \
    --member="serviceAccount:$GCLOUD_CLUSTER-gcr-access@$GCLOUD_PROJECT.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"
```
and the `cloudsql.client` to the `$GCLOUD_CLUSTER-gcr-access` serviceAccount.
```
gcloud projects add-iam-policy-binding $GCLOUD_PROJECT \
    --member="serviceAccount:$GCLOUD_CLUSTER-gcr-access@$GCLOUD_PROJECT.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client"
```

Last step  is to create a key file named `key.json`

```
gcloud iam service-accounts keys create key.json \
  --iam-account="$GCLOUD_CLUSTER-gcr-access@$PROJECT_ID$GCLOUD_PROJECT.iam.gserviceaccount.com"
```

### Create regional ip address

```
gcloud compute addresses create datacater-gcp-ip --global
```
Validate the creation with:
```
gcloud compute addresses describe datacater-gcp-ip --global
```
The output should contain `status: RESERVED` as the last line.
Please map this as an `A-Record` entry in [CloudDNS](https://console.cloud.google.com/net-services/dns)
for your desired domain.
