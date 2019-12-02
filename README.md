<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS EKS
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module will be created Autoscaling, Workers, EKS.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.12-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-eks'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+EKS&url=https://github.com/clouddrove/terraform-aws-eks'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+EKS&url=https://github.com/clouddrove/terraform-aws-eks'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards stratergies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 0.12](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)




## What Includes

- [Autoscale](modules/autoscale/README.md)
- [EKS](modules/eks/README.md)
- [Worker](modules/worker/README.md)






## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-eks/releases).


### Sample example
Here is an example of how you can use this module in your inventory structure:
```hcl
module "eks-cluster" {
  source = "git::https://github.com/clouddrove/terraform-aws-eks.git?ref=tags/0.12.2"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  enabled     = true
  label_order = ["environment", "name", "application"]

  ## Network
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnets.public_subnet_id
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = []
  additional_security_group_ids   = [module.ssh.security_group_ids]
  endpoint_private_access         = false
  endpoint_public_access          = true

  ## Ec2
  key_name      = module.keypair.name
  image_id      = "ami-0dd0a16a2bd0784b8"
  instance_type = "t3.small"
  max_size      = 3
  min_size      = 1
  volume_size   = 20

  ## Spot
  spot_enabled                = true
  spot_max_size               = 3
  spot_min_size               = 1
  max_price                   = "0.20"
  spot_instance_type          = "m5.large"
  associate_public_ip_address = true

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true
  kubernetes_version        = "1.14"

  ## Schedule
  scheduler_down          = "0 19 * * MON-FRI"
  scheduler_up            = "0 6 * * MON-FRI"
  min_size_scaledown      = 0
  max_size_scaledown      = 1
  spot_min_size_scaledown = 0
  spot_max_size_scaledown = 1

  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"

  ## ebs encryption
  ebs_encryption = false

  ## logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_security_group_ids | Additional list of security groups that will be attached to the autoscaling group. | list(string) | `<list>` | no |
| allowed_cidr_blocks_cluster | List of CIDR blocks to be allowed to connect to the EKS cluster. | list(string) | `<list>` | no |
| allowed_cidr_blocks_workers | List of CIDR blocks to be allowed to connect to the worker nodes. | list(string) | `<list>` | no |
| allowed_security_groups_cluster | List of Security Group IDs to be allowed to connect to the EKS cluster. | list(string) | `<list>` | no |
| allowed_security_groups_workers | List of Security Group IDs to be allowed to connect to the worker nodes. | list(string) | `<list>` | no |
| application | Application (e.g. `cd` or `clouddrove`). | string | `` | no |
| apply_config_map_aws_auth | Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster. | bool | `true` | no |
| associate_public_ip_address | Associate a public IP address with the worker nodes in the VPC. | bool | `true` | no |
| attributes | Additional attributes (e.g. `1`). | list | `<list>` | no |
| autoscaling_policies_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling. | bool | `true` | no |
| cpu_utilization_high_threshold_percent | Worker nodes AutoScaling Group CPU utilization high threshold percent. | number | `80` | no |
| cpu_utilization_low_threshold_percent | Worker nodes AutoScaling Group CPU utilization low threshold percent. | number | `20` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | string | `-` | no |
| ebs_encryption | Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot_id. | bool | `false` | no |
| eks_subnet_ids | A list of subnet IDs to launch resources in EKS. | list(string) | `<list>` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | bool | `true` | no |
| enabled_cluster_log_types | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]. | list(string) | `<list>` | no |
| endpoint_private_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false. | bool | `false` | no |
| endpoint_public_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true. | bool | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | string | `` | no |
| health_check_type | Controls how health checking is done. Valid values are `EC2` or `ELB`. | string | `EC2` | no |
| image_id | EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images. | string | `` | no |
| instance_interruption_behavior | The behavior when a Spot Instance is interrupted. Can be hibernate, stop, or terminate. (Default: terminate). | string | `terminate` | no |
| instance_type | Instance type to launch. | string | `t2.nano` | no |
| key_name | SSH key name that should be used for the instance. | string | `` | no |
| kms_key | AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set. | string | `` | no |
| kubernetes_version | Desired Kubernetes master version. If you do not specify a value, the latest available version is used. | string | `` | no |
| label_order | Label order, e.g. `name`,`application`. | list | `<list>` | no |
| max_price | The maximum hourly price you're willing to pay for the Spot Instances. | string | `` | no |
| max_size | The maximum size of the AutoScaling Group. | string | `1` | no |
| max_size_scaledown | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | number | `1` | no |
| min_size | The minimum size of the AutoScaling Group. | string | `1` | no |
| min_size_scaledown | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | number | `0` | no |
| name | Name  (e.g. `app` or `cluster`). | string | `` | no |
| scheduler_down | What is the recurrency for scaling up operations ? | string | `0 19 * * MON-FRI` | no |
| scheduler_up | What is the recurrency for scaling down operations ? | string | `0 6 * * MON-FRI` | no |
| spot_enabled | Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances. | bool | `false` | no |
| spot_instance_type | Sport instance type to launch. | string | `t2.medium` | no |
| spot_max_size | The maximum size of the spot autoscale group. | number | `5` | no |
| spot_max_size_scaledown | The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | number | `1` | no |
| spot_min_size | The minimum size of the spot autoscale group. | number | `2` | no |
| spot_min_size_scaledown | The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | number | `0` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | map | `<map>` | no |
| use_existing_security_group | If set to `true`, will use variable `workers_security_group_id` to run EKS workers using an existing security group that was created outside of this module, workaround for errors like `count cannot be computed`. | bool | `false` | no |
| volume_size | The size of ebs volume. | number | `20` | no |
| volume_type | The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`). | string | `standard` | no |
| vpc_id | VPC ID for the EKS cluster. | string | `` | no |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | string | `15m` | no |
| worker_subnet_ids | A list of subnet IDs to launch resources in workers. | list(string) | `<list>` | no |
| workers_security_group_id | The name of the existing security group that will be used in autoscaling group for EKS workers. If empty, a new security group will be created. | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| config_map_aws_auth | Kubernetes ConfigMap configuration to allow the worker nodes to join the EKS cluster. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#required-kubernetes-configuration-to-join-worker-nodes. |
| eks_cluster_arn | The Amazon Resource Name (ARN) of the cluster. |
| eks_cluster_certificate_authority_data | The base64 encoded certificate data required to communicate with the cluster. |
| eks_cluster_endpoint | The endpoint for the Kubernetes API server. |
| eks_cluster_id | The name of the cluster. |
| eks_cluster_security_group_arn | ARN of the EKS cluster Security Group. |
| eks_cluster_security_group_id | ID of the EKS cluster Security Group. |
| eks_cluster_security_group_name | Name of the EKS cluster Security Group. |
| eks_cluster_version | The Kubernetes server version of the cluster. |
| kubeconfig | `kubeconfig` configuration to connect to the cluster using `kubectl`. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#configuring-kubectl-for-eks. |
| tags | A mapping of tags to assign to the resource. |
| workers_autoscaling_group_arn | ARN of the AutoScaling Group. |
| workers_autoscaling_group_default_cooldown | Time between a scaling activity and the succeeding scaling activity. |
| workers_autoscaling_group_desired_capacity | The number of Amazon EC2 instances that should be running in the group. |
| workers_autoscaling_group_health_check_grace_period | Time after instance comes into service before checking health. |
| workers_autoscaling_group_health_check_type | `EC2` or `ELB`. Controls how health checking is done. |
| workers_autoscaling_group_id | The AutoScaling Group ID. |
| workers_autoscaling_group_max_size | The maximum size of the AutoScaling Group. |
| workers_autoscaling_group_min_size | The minimum size of the AutoScaling Group. |
| workers_autoscaling_group_name | The AutoScaling Group name. |
| workers_launch_template_arn | ARN of the launch template. |
| workers_launch_template_id | ID of the launch template. |
| workers_security_group_arn | ARN of the worker nodes Security Group. |
| workers_security_group_id | ID of the worker nodes Security Group. |
| workers_security_group_name | Name of the worker nodes Security Group. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-eks/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-eks)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=