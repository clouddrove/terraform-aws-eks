<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS EKS
</h1>

<p align="center" style="font-size: 1.2rem;">
    Terraform module will be created Autoscaling, Workers, EKS, Node Groups.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.13-green" alt="Terraform">
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


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure.

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies:

- [Terraform 0.13](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-eks/releases).


### Sample example
Here is an example of how you can use this module in your inventory structure:
```hcl
module "eks-cluster" {
     source = "../../"

     ## Tags
     name        = "eks"
     application = "clouddrove"
     environment = "test"
     label_order = ["environment", "application", "name"]
     enabled     = true

     ## Network
     vpc_id                              = module.vpc.vpc_id
     eks_subnet_ids                      = module.subnets.public_subnet_id
     worker_subnet_ids                   = module.subnets.private_subnet_id
     allowed_security_groups_cluster     = []
     allowed_security_groups_workers     = []
     additional_security_group_ids       = [module.ssh.security_group_ids]
     endpoint_private_access             = false
     endpoint_public_access              = true
     public_access_cidrs                 = ["0.0.0.0/0"]
     cluster_encryption_config_resources = ["secrets"]
     associate_public_ip_address         = false
     key_name                            = module.keypair.name

     ## volume_size
     volume_size = 20

     ## ondemand
     ondemand_enabled          = true
     ondemand_instance_type    = ["t3.small", "t3.medium", "t3.small"]
     ondemand_max_size         = [1, 0, 0]
     ondemand_min_size         = [1, 0, 0]
     ondemand_desired_capacity = [1, 0, 0]

     ondemand_schedule_enabled            = true
     ondemand_schedule_max_size_scaleup   = [0, 0, 0]
     ondemand_schedule_desired_scaleup    = [0, 0, 0]
     ondemand_schedule_min_size_scaleup   = [0, 0, 0]
     ondemand_schedule_min_size_scaledown = [0, 0, 0]
     ondemand_schedule_max_size_scaledown = [0, 0, 0]
     ondemand_schedule_desired_scale_down = [0, 0, 0]


     ## Spot
     spot_enabled          = true
     spot_instance_type    = ["t3.small", "t3.medium", "t3.small"]
     spot_max_size         = [1, 0, 0]
     spot_min_size         = [1, 0, 0]
     spot_desired_capacity = [1, 0, 0]
     max_price             = ["0.20", "0.20", "0.20"]

     spot_schedule_enabled            = true
     spot_schedule_min_size_scaledown = [0, 0, 0]
     spot_schedule_max_size_scaledown = [0, 0, 0]
     spot_schedule_desired_scale_down = [0, 0, 0]
     spot_schedule_desired_scaleup    = [0, 0, 0]
     spot_schedule_max_size_scaleup   = [0, 0, 0]
     spot_schedule_min_size_scaleup   = [0, 0, 0]

     ## Schedule time
     scheduler_down = "0 19 * * MON-FRI" #diffrent
     scheduler_up   = "0 6 * * MON-FRI"

     #node_group
     node_groups                     = var.node_groups
     node_group_enabled              = true
     before_cluster_joining_userdata = ""

     ## Cluster
     wait_for_capacity_timeout = "15m"
     apply_config_map_aws_auth = true
     kubernetes_version        = "1.18"
     map_additional_iam_users = [
       {
         userarn  = "arn:aws:iam::924144197303:user/anmol@clouddrove.com"
         username = "anmol@clouddrove.com"
         groups   = ["system:masters"]
       },
       {
         userarn  = "arn:aws:iam::924144197303:user/nikita@clouddrove.com"
         username = "nikita@clouddrove.com"
         groups   = ["system:masters"]
       }

     ]

     ## Health Checks
     cpu_utilization_high_threshold_percent = 80
     cpu_utilization_low_threshold_percent  = 20
     health_check_type                      = "EC2"

     ## EBS Encryption
     ebs_encryption = true

     ## logs
     enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    }
 ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ids | Additional list of security groups that will be attached to the autoscaling group. | `list(string)` | `[]` | no |
| allowed\_cidr\_blocks\_cluster | List of CIDR blocks to be allowed to connect to the EKS cluster. | `list(string)` | `[]` | no |
| allowed\_cidr\_blocks\_workers | List of CIDR blocks to be allowed to connect to the worker nodes. | `list(string)` | `[]` | no |
| allowed\_security\_groups\_cluster | List of Security Group IDs to be allowed to connect to the EKS cluster. | `list(string)` | `[]` | no |
| allowed\_security\_groups\_workers | List of Security Group IDs to be allowed to connect to the worker nodes. | `list(string)` | `[]` | no |
| ami\_release\_version | AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version | `string` | `""` | no |
| ami\_type | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided | `string` | `"AL2_x86_64"` | no |
| application | Application (e.g. `cd` or `clouddrove`). | `string` | `""` | no |
| apply\_config\_map\_aws\_auth | Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster. | `bool` | `true` | no |
| associate\_public\_ip\_address | Associate a public IP address with the worker nodes in the VPC. | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`). | `list` | `[]` | no |
| before\_cluster\_joining\_userdata | Additional commands to execute on each worker node before joining the EKS cluster (before executing the `bootstrap.sh` script). For more info, see https://kubedex.com/90-days-of-aws-eks-in-production | `string` | `""` | no |
| cluster\_encryption\_config\_enabled | Set to `true` to enable Cluster Encryption Configuration | `bool` | `false` | no |
| cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days | Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction | `number` | `10` | no |
| cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation | Cluster Encryption Config KMS Key Resource argument - enable kms key rotation | `bool` | `true` | no |
| cluster\_encryption\_config\_kms\_key\_policy | Cluster Encryption Config KMS Key Resource argument - key policy | `string` | `null` | no |
| cluster\_encryption\_config\_resources | Cluster Encryption Config Resources to encrypt, e.g. ['secrets'] | `list` | <pre>[<br>  "secrets"<br>]</pre> | no |
| cluster\_log\_retention\_period | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `0` | no |
| cluster\_namespace | Kubernetes namespace for selection | `string` | `""` | no |
| cpu\_utilization\_high\_threshold\_percent | Worker nodes AutoScaling Group CPU utilization high threshold percent. | `number` | `80` | no |
| cpu\_utilization\_low\_threshold\_percent | Worker nodes AutoScaling Group CPU utilization low threshold percent. | `number` | `20` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | `string` | `"-"` | no |
| ebs\_encryption | Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot\_id. | `bool` | `false` | no |
| eks\_subnet\_ids | A list of subnet IDs to launch resources in EKS. | `list(string)` | `[]` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | `bool` | `true` | no |
| enabled\_cluster\_log\_types | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]. | `list(string)` | `[]` | no |
| endpoint\_private\_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false. | `bool` | `false` | no |
| endpoint\_public\_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| fargate\_enabled | Whether fargate profile is enabled or not | `bool` | `false` | no |
| health\_check\_type | Controls how health checking is done. Valid values are `EC2` or `ELB`. | `string` | `"EC2"` | no |
| image\_id | EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images. | `string` | `""` | no |
| instance\_interruption\_behavior | The behavior when a Spot Instance is interrupted. Can be hibernate, stop, or terminate. (Default: terminate). | `string` | `"terminate"` | no |
| key\_name | SSH key name that should be used for the instance. | `string` | `""` | no |
| kms\_key\_arn | The ARN of the KMS Key | `string` | `""` | no |
| kubernetes\_config\_map\_ignore\_role\_changes | Set to `true` to ignore IAM role changes in the Kubernetes Auth ConfigMap | `bool` | `true` | no |
| kubernetes\_version | Desired Kubernetes master version. If you do not specify a value, the latest available version is used. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list` | `[]` | no |
| local\_exec\_interpreter | shell to use for local\_exec | `list(string)` | <pre>[<br>  "/bin/sh",<br>  "-c"<br>]</pre> | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"anmol@clouddrove.com"` | no |
| map\_additional\_aws\_accounts | Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap | `list(string)` | `[]` | no |
| map\_additional\_iam\_roles | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_additional\_iam\_users | Additional IAM users to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| max\_price | The maximum hourly price you're willing to pay for the Spot Instances. | `list` | `[]` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| node\_group\_enabled | Enabling or disabling the node group. | `bool` | `false` | no |
| node\_groups | Node group configurations | `map(object)` |  <pre>map(object({<br>    node_group_name           = string<br>    subnet_ids                = list(string)<br>    ami_type                  = string<br>node_group_volume_size    = number<br>node_group_instance_types = list(string)<br>node_group_instance_types = list(string)<br>kubernetes_labels         = map(string)<br>kubernetes_version        = string<br>node_group_desired_size   = number<br>node_group_max_size       = number<br>node_group_min_size       = number <br>       }))</pre> | no |
| node\_security\_group\_ids | Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. | `list(string)` | `[]` | no |
| oidc\_provider\_enabled | Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html | `bool` | `false` | no |
| ondemand\_desired\_capacity | The desired size of the autoscale group. | `list` | `[]` | no |
| ondemand\_desired\_size | Desired number of worker nodes | `number` | `2` | no |
| ondemand\_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling. | `bool` | `false` | no |
| ondemand\_instance\_type | Instance type to launch. | `list` | `[]` | no |
| ondemand\_max\_size | The maximum size of the autoscale group. | `list` | `[]` | no |
| ondemand\_min\_size | The minimum size of the autoscale group. | `list` | `[]` | no |
| ondemand\_scale\_up\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `1` | no |
| ondemand\_schedule\_desired\_scale\_down | The number of Amazon EC2 instances that should be running in the group. | `list` | `[]` | no |
| ondemand\_schedule\_desired\_scaleup | The schedule desired size of the autoscale group. | `list` | `[]` | no |
| ondemand\_schedule\_enabled | AutoScaling Schedule resource | `bool` | `false` | no |
| ondemand\_schedule\_max\_size\_scaledown | The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `list` | `[]` | no |
| ondemand\_schedule\_max\_size\_scaleup | The schedule maximum size of the autoscale group. | `list` | `[]` | no |
| ondemand\_schedule\_min\_size\_scaledown | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `list` | `[]` | no |
| ondemand\_schedule\_min\_size\_scaleup | The schedule minimum size of the autoscale group. | `list` | `[]` | no |
| public\_access\_cidrs | The list of cidr blocks to access AWS EKS cluster endpoint. Default [`0.0.0.0/0`] | `list(string)` | `[]` | no |
| scheduler\_down | What is the recurrency for scaling up operations ? | `string` | `"0 19 * * MON-FRI"` | no |
| scheduler\_up | What is the recurrency for scaling down operations ? | `string` | `"0 6 * * MON-FRI"` | no |
| spot\_desired\_capacity | The number of Amazon EC2 instances that should be running in the group. | `list` | `[]` | no |
| spot\_enabled | Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances. | `bool` | `false` | no |
| spot\_instance\_type | Sport instance type to launch. | `list` | `[]` | no |
| spot\_max\_size | The maximum size of the spot autoscale group. | `list` | `[]` | no |
| spot\_min\_size | The minimum size of the spot autoscale group. | `list` | `[]` | no |
| spot\_scale\_up\_desired | The number of Amazon EC2 instances that should be running in the group. | `list` | `[]` | no |
| spot\_schedule\_desired\_scale\_down | The number of Amazon EC2 instances that should be running in the group. | `list` | `[]` | no |
| spot\_schedule\_desired\_scaleup | The schedule desired size of the autoscale group. | `list` | `[]` | no |
| spot\_schedule\_enabled | AutoScaling Schedule resource for spot | `bool` | `false` | no |
| spot\_schedule\_max\_size\_scaledown | The maximum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `list` | `[]` | no |
| spot\_schedule\_max\_size\_scaleup | The schedule maximum size of the autoscale group. | `list` | `[]` | no |
| spot\_schedule\_min\_size\_scaledown | The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `list` | `[]` | no |
| spot\_schedule\_min\_size\_scaleup | The schedule minimum size of the autoscale group. | `list` | `[]` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map` | `{}` | no |
| use\_existing\_security\_group | If set to `true`, will use variable `workers_security_group_id` to run EKS workers using an existing security group that was created outside of this module, workaround for errors like `count cannot be computed`. | `bool` | `false` | no |
| volume\_size | The size of ebs volume. | `number` | `20` | no |
| volume\_type | The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`). | `string` | `"standard"` | no |
| vpc\_id | VPC ID for the EKS cluster. | `string` | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"15m"` | no |
| wait\_for\_cluster\_command | `local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT` | `string` | `"curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"` | no |
| worker\_subnet\_ids | A list of subnet IDs to launch resources in workers. | `list(string)` | `[]` | no |
| workers\_security\_group\_id | The name of the existing security group that will be used in autoscaling group for EKS workers. If empty, a new security group will be created. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| eks\_cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| eks\_cluster\_certificate\_authority\_data | The base64 encoded certificate data required to communicate with the cluster. |
| eks\_cluster\_endpoint | The endpoint for the Kubernetes API server. |
| eks\_cluster\_id | The name of the cluster. |
| eks\_cluster\_security\_group\_arn | ARN of the EKS cluster Security Group. |
| eks\_cluster\_security\_group\_id | ID of the EKS cluster Security Group. |
| eks\_cluster\_security\_group\_name | Name of the EKS cluster Security Group. |
| eks\_cluster\_version | The Kubernetes server version of the cluster. |
| eks\_fargate\_arn | Amazon Resource Name (ARN) of the EKS Fargate Profile. |
| eks\_fargate\_id | EKS Cluster name and EKS Fargate Profile name separated by a colon (:). |
| iam\_role\_arn | ARN of the worker nodes IAM role. |
| kubernetes\_config\_map\_id | ID of `aws-auth` Kubernetes ConfigMap |
| tags | A mapping of tags to assign to the resource. |
| workers\_autoscaling\_group\_arn | ARN of the AutoScaling Group. |
| workers\_autoscaling\_group\_default\_cooldown | Time between a scaling activity and the succeeding scaling activity. |
| workers\_autoscaling\_group\_desired\_capacity | The number of Amazon EC2 instances that should be running in the group. |
| workers\_autoscaling\_group\_health\_check\_grace\_period | Time after instance comes into service before checking health. |
| workers\_autoscaling\_group\_health\_check\_type | `EC2` or `ELB`. Controls how health checking is done. |
| workers\_autoscaling\_group\_id | The AutoScaling Group ID. |
| workers\_autoscaling\_group\_max\_size | The maximum size of the AutoScaling Group. |
| workers\_autoscaling\_group\_min\_size | The minimum size of the AutoScaling Group. |
| workers\_autoscaling\_group\_name | The AutoScaling Group name. |
| workers\_launch\_template\_arn | ARN of the launch template. |
| workers\_launch\_template\_id | ID of the launch template. |
| workers\_security\_group\_arn | ARN of the worker nodes Security Group. |
| workers\_security\_group\_id | ID of the worker nodes Security Group. |
| workers\_security\_group\_name | Name of the worker nodes Security Group. |




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
