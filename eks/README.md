# datacater-helm-chart
Helm chart for deploying DataCater on Elast Kubernetes Service (EKS).

1. Make sure you are logged in to the right account and region for the setup.
  ```bash
  aws sts get-caller-identity
  cat ~/.aws/config <-- make sure you are using the profile you want.
  ```

2. Create you eks cluster with recommended config
  ```bash
  eksctl create cluster -f eks/cluster.yml
  ```

3. Create a Container registry. **NOTE** we will retrieve the password for this
registry via
```bash
aws ecr get-login-password --region eu-central-1
```

4. Copy and fill out our env.template file.

5. Create all the secrets needed by executing:

```bash
bash ./create_secrets.sh
```

**NOTE**: You are done and can reach the datacater web interface by port-forwarding at this stage.

We also deploy a simple ingress, which you can adjust. But for that you need to first install the
EKS AWS LoadBalancer Controller.

6. Follow the documentation for installing [AWS LoadBalancer](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)


