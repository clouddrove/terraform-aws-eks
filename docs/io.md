## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_entries | Map of access entries to add to the cluster | `map(any)` | `{}` | no |
| addons | Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources. | `any` | `[]` | no |
| allowed\_cidr\_blocks | List of CIDR blocks to be allowed to connect to the EKS cluster. | `list(string)` | `[]` | no |
| allowed\_security\_groups | List of Security Group IDs to be allowed to connect to the EKS cluster. | `list(string)` | `[]` | no |
| apply\_config\_map\_aws\_auth | Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster. | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| authentication\_mode | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"CONFIG_MAP"` | no |
| bootstrap\_self\_managed\_addons | Indicates whether or not to bootstrap self-managed addons after the cluster has been created | `bool` | `null` | no |
| cluster\_compute\_config | Configuration block for the cluster compute configuration | `any` | `{}` | no |
| cluster\_encryption\_config\_enabled | Set to `true` to enable Cluster Encryption Configuration | `bool` | `true` | no |
| cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days | Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction | `number` | `10` | no |
| cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation | Cluster Encryption Config KMS Key Resource argument - enable kms key rotation | `bool` | `true` | no |
| cluster\_encryption\_config\_kms\_key\_policy | Cluster Encryption Config KMS Key Resource argument - key policy | `string` | `null` | no |
| cluster\_encryption\_config\_resources | Cluster Encryption Config Resources to encrypt, e.g. ['secrets'] | `list(any)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| cluster\_ip\_family | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `null` | no |
| cluster\_log\_retention\_period | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `30` | no |
| cluster\_name | Name of eks cluster | `string` | `""` | no |
| cluster\_remote\_network\_config | Configuration block for the cluster remote network configuration | `any` | `{}` | no |
| cluster\_service\_ipv4\_cidr | The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks | `string` | `null` | no |
| cluster\_service\_ipv6\_cidr | The CIDR block to assign Kubernetes pod and service IP addresses from if `ipv6` was specified when the cluster was created. Kubernetes assigns service addresses from the unique local address range (fc00::/7) because you can't specify a custom IPv6 CIDR block when you create the cluster | `string` | `null` | no |
| cluster\_timeouts | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| cluster\_upgrade\_policy | Configuration block for the cluster upgrade policy | `any` | `{}` | no |
| cluster\_zonal\_shift\_config | Configuration block for the cluster zonal shift | `any` | `{}` | no |
| create | Controls if resources should be created (affects nearly all resources) | `bool` | `false` | no |
| create\_node\_iam\_role | Determines whether an EKS Auto node IAM role is created | `bool` | `true` | no |
| create\_schedule | Determines whether to create autoscaling group schedule or not | `bool` | `true` | no |
| eks\_additional\_security\_group\_ids | EKS additional security group id | `list(string)` | `[]` | no |
| eks\_tags | Additional tags for EKS Cluster only. | `map(any)` | `{}` | no |
| enable\_cluster\_creator\_admin\_permissions | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `true` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | `bool` | `true` | no |
| enabled\_cluster\_log\_types | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]. | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| endpoint\_private\_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false. | `bool` | `true` | no |
| endpoint\_public\_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| external\_cluster | Set to true to create an AWS-managed node group for an existing EKS cluster. Assumes the EKS cluster is already provisioned. | `bool` | `false` | no |
| fargate\_enabled | Whether fargate profile is enabled or not | `bool` | `false` | no |
| fargate\_profiles | The number of Fargate Profiles that would be created. | `map(any)` | `{}` | no |
| iam\_role\_additional\_policies | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| kubernetes\_version | Desired Kubernetes master version. If you do not specify a value, the latest available version is used. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| local\_exec\_interpreter | shell to use for local\_exec | `list(string)` | <pre>[<br>  "/bin/sh",<br>  "-c"<br>]</pre> | no |
| managed\_node\_group | Map of eks-managed node group definitions to create | `any` | `{}` | no |
| managed\_node\_group\_defaults | Map of eks-managed node group definitions to create | `any` | `{}` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"hello@clouddrove.com"` | no |
| map\_additional\_aws\_accounts | Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap | `list(string)` | `[]` | no |
| map\_additional\_iam\_roles | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_additional\_iam\_users | Additional IAM users to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| node\_iam\_role\_additional\_policies | Additional policies to be added to the EKS Auto node IAM role | `map(string)` | `{}` | no |
| node\_iam\_role\_description | Description of the EKS Auto node IAM role | `string` | `null` | no |
| node\_iam\_role\_name | Name to use on the EKS Auto node IAM role created | `string` | `null` | no |
| node\_iam\_role\_path | The EKS Auto node IAM role path | `string` | `null` | no |
| node\_iam\_role\_permissions\_boundary | ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role | `string` | `null` | no |
| node\_iam\_role\_tags | A map of additional tags to add to the EKS Auto node IAM role created | `map(string)` | `{}` | no |
| node\_iam\_role\_use\_name\_prefix | Determines whether the EKS Auto node IAM role name (`node_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| node\_role\_arn | IAM Role ARN to be used by NodeGroup. Refer to https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html for more details. | `string` | `""` | no |
| nodes\_additional\_security\_group\_ids | EKS additional node group ids | `list(string)` | `[]` | no |
| oidc\_provider\_enabled | Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html | `bool` | `true` | no |
| openid\_connect\_audiences | List of OpenID Connect audience client IDs to add to the IRSA provider | `list(string)` | `[]` | no |
| outpost\_config | Configuration for the AWS Outpost to provision the cluster on | `any` | `{}` | no |
| permissions\_boundary | If provided, all IAM roles will be created with this permissions boundary attached. | `string` | `null` | no |
| public\_access\_cidrs | Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| region | AWS region to create the EKS cluster in | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-eks"` | no |
| schedules | Map of autoscaling group schedule to create | `map(any)` | `{}` | no |
| self\_node\_group\_defaults | Map of self-managed node group default configurations | `any` | `{}` | no |
| self\_node\_groups | Map of self-managed node group definitions to create | `any` | `{}` | no |
| subnet\_filter\_name | The name of the subnet filter (e.g., tag:kubernetes.io/cluster/CLUSTER\_NAME) | `string` | `""` | no |
| subnet\_filter\_values | List of values for the subnet filter (e.g., owned, shared) | `list(string)` | `[]` | no |
| subnet\_ids | A list of subnet IDs to launch the cluster in. | `list(string)` | `[]` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(any)` | `{}` | no |
| vpc\_id | VPC ID for the EKS cluster. | `string` | `""` | no |
| vpc\_security\_group\_ids | A list of security group IDs to associate | `list(string)` | `[]` | no |
| wait\_for\_cluster\_command | `local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT` | `string` | `"curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster |
| cluster\_certificate\_authority\_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster\_endpoint | Endpoint for your Kubernetes API server |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster |
| cluster\_iam\_role\_unique\_id | Stable and unique string identifying the IAM role |
| cluster\_id | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| cluster\_name | n/a |
| cluster\_oidc\_issuer\_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| cluster\_platform\_version | Platform version for the cluster |
| cluster\_primary\_security\_group\_id | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use default security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| cluster\_status | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| node\_group\_iam\_role\_arn | IAM role ARN of the EKS cluster |
| node\_group\_iam\_role\_name | IAM role name of the EKS cluster |
| node\_group\_iam\_role\_unique\_id | Stable and unique string identifying the IAM role |
| node\_security\_group\_arn | Amazon Resource Name (ARN) of the node shared security group |
| node\_security\_group\_id | ID of the node shared security group |
| oidc\_provider\_arn | The ARN of the OIDC Provider if `enable_irsa = true` |
| tags | n/a |

