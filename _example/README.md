# Other Configurations

This below README tells about the configuration to do after deploying terraform modules on AWS.

## 1. fargate

A. As I have used `kube-system` namespace in `example.tf` file -

Line Number - 186 - `cluster_namespace = "kube-system"`, so basically I am only using Fargate for my nodes and pods that are deployed on those nodes this means that `CoreDNS` deployment will also be on Fargate.

B. By default, CoreDNS is configured to run on Amazon EC2 infrastructure on Amazon EKS clusters. If you want to only run your pods on Fargate in your cluster, you need to modify the CoreDNS deployment to remove the `eks.amazonaws.com/compute-type : ec2` annotation.

To do this execute the following command -

```sh
kubectl patch deployment coredns -n kube-system --type json \
-p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
```

C. Delete and re-create any existing pods so that they are scheduled on Fargate. For example, the following command triggers a rollout of the coredns Deployment. You can modify the namespace and deployment type to update your specific pods.

```sh
kubectl rollout restart -n kube-system deployment coredns
```

D. Reference link for more information - [AWS EKS Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html)

### Limitation

When we deploy the module `fargate` it deploys successfully, but if we want to destroy the whole terraform module then `Please first manually delete the Fargate Profile in EKS` because when we do `terraform destroy` the timeout error comes while terraform deletes `Fargate Profile` and after successful deletion of `Fargate Profile` then do `terraform destroy`.

## 2. node-group

After deploying the terraform module their are some extra configuration to enable `AWS Cluster Autoscaler` -

A. Download the below file -

```sh
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

B. Edit below lines in the above downloaded file -

1. Edit the cluster-autoscaler container command to replace <YOUR CLUSTER NAME> with your cluster's name, and add the following options.

```sh
--balance-similar-node-groups
--skip-nodes-with-system-pods=false
```

`--balance-similar-node-groups` = Cluster autoscaler does not support Auto Scaling Groups which span multiple Availability Zones; instead you should use an Auto Scaling Group for each Availability Zone and enable the --balance-similar-node-groups feature. If you do use a single Auto Scaling Group that spans multiple Availability Zones you will find that AWS unexpectedly terminates nodes without them being drained because of the rebalancing feature.

`--skip-nodes-with-system-pods=false` = By default, cluster autoscaler will not terminate nodes running pods in the kube-system namespace. You can override this default behaviour by passing in the --skip-nodes-with-system-pods=false flag.

The configuration becomes -

```sh
    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

2. In line number `141` in the above file replace `v1.14.7` to `v1.16.6`.

The Github Repository link for reference - [Github Link](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)

To Test the scale out of the EKS worker nodes - [AWS EKS Autoscaler](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-autoscaler-setup/)

## 3. without-fargate

After deploying the terraform module their are some extra configuration to enable `AWS Cluster Autoscaler` -

A. Download the below file -

```sh
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

B. Edit below lines in the above downloaded file -

1. Edit the cluster-autoscaler container command to replace <YOUR CLUSTER NAME> with your cluster's name, and add the following options.

```sh
--balance-similar-node-groups
--skip-nodes-with-system-pods=false
```

`--balance-similar-node-groups` = Cluster autoscaler does not support Auto Scaling Groups which span multiple Availability Zones; instead you should use an Auto Scaling Group for each Availability Zone and enable the --balance-similar-node-groups feature. If you do use a single Auto Scaling Group that spans multiple Availability Zones you will find that AWS unexpectedly terminates nodes without them being drained because of the rebalancing feature.

`--skip-nodes-with-system-pods=false` = By default, cluster autoscaler will not terminate nodes running pods in the kube-system namespace. You can override this default behaviour by passing in the --skip-nodes-with-system-pods=false flag.

The configuration becomes -

```sh
    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

2. In line number `141` in the above file replace `v1.14.7` to `v1.16.6`.

The Github Repository link for reference - [Github Link](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)

To Test the scale out of the EKS worker nodes - [AWS EKS Autoscaler](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-autoscaler-setup/)

## 4. public-ip

A. Before deploying the module edit the public ip with your public ip in line `60` and `181` -

```sh
60.  - allowed_ip          = ["Your Public IP/32", module.vpc.vpc_cidr_block]
181. - public_access_cidrs = ["Your Public IP/32"]
```

B. After deploying the terraform module their are some extra configuration to enable `AWS Cluster Autoscaler` -

1. Download the below file -

```sh
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

2. Edit below lines in the above downloaded file -

A. Edit the cluster-autoscaler container command to replace <YOUR CLUSTER NAME> with your cluster's name, and add the following options.

```sh
--balance-similar-node-groups
--skip-nodes-with-system-pods=false
```

`--balance-similar-node-groups` = Cluster autoscaler does not support Auto Scaling Groups which span multiple Availability Zones; instead you should use an Auto Scaling Group for each Availability Zone and enable the --balance-similar-node-groups feature. If you do use a single Auto Scaling Group that spans multiple Availability Zones you will find that AWS unexpectedly terminates nodes without them being drained because of the rebalancing feature.

`--skip-nodes-with-system-pods=false` = By default, cluster autoscaler will not terminate nodes running pods in the kube-system namespace. You can override this default behaviour by passing in the --skip-nodes-with-system-pods=false flag.

The configuration becomes -

```sh
    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

B. In line number `141` in the above file replace `v1.14.7` to `v1.16.6`.

The Github Repository link for reference - [Github Link](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws)

To Test the scale out of the EKS worker nodes - [AWS EKS Autoscaler](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-autoscaler-setup/)
