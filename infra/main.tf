data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}



### gpg keys

resource "gpg_private_key" "ksops_key" {
  name       = "Foo Bar"
  email      = "foo@bar.com"
  rsa_bits   = 4096
}


### kubernetes

locals {
  cluster_name                     = var.cluster_name
  aws_region                       = data.aws_region.current.name
  aws_account                      = data.aws_caller_identity.current.account_id
  external_secret_role_name_prefix = "external-secrets"
  cluster_version                  = "1.21"

  tags = {
    "cluster-name" : var.cluster_name
  }

}


## Network (VPC and Subnets)


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.10.0"

  name                 = var.cluster_name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = local.tags
}


## EKS Cluster

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  write_kubeconfig                = false #default is false. We don't want to create it as we'll use the AWS CLI for this.
  manage_aws_auth                 = false #set this to false as this will require using a Kubernetes providers. It is generally a bad idea to use a Kuberetes provide in the same Terraform code that is building the cluster
  manage_cluster_iam_resources    = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_version                 = local.cluster_version
  cluster_name                    = var.cluster_name
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  tags                            = local.tags
  enable_irsa                     = true



  worker_groups = [
    {
      name                 = "medium"
      instance_type        = "t3.medium"
      asg_desired_capacity = 1
      asg_min_size         = 0
      asg_max_size         = 4
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]

}


### IAM Roles for Service Accounts

module "irsa_external_secrets" {
  source                  = "./irsa"
  cluster_name            = module.eks.cluster_id
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  policy_string = templatefile(
    "./iam_policy_templates/external-secret.tpl", # this policy allows the Service Account that the ExternalSecrets Service Account binds to, to assume the roles needed in order to access Secret Manager Secrets
    {
      "aws_account"                      = local.aws_account
      "external_secret_role_name_prefix" = local.external_secret_role_name_prefix
      "cluster_name"                     = local.cluster_name
    }
  )
  namespace       = "kube-system"
  service_account = "external-secrets"
  tags            = local.tags
}

module "irsa_rok_tools" {
  source                  = "./irsa"
  cluster_name            = module.eks.cluster_id
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  policy_string = templatefile(
    "./iam_policy_templates/rok-tools.tpl",
    {
      "cluster_name" = var.cluster_name
    }
  )
  namespace       = "rok-tools"
  service_account = "rok-tools"
  tags            = local.tags
}


module "irsa_cluster_autoscaler" {
  source                  = "./irsa"
  cluster_name            = module.eks.cluster_id
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  policy_string = templatefile(
    "./iam_policy_templates/cluster-autoscaler.tpl",
    {
      "cluster_name" = var.cluster_name
    }
  )
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  tags            = local.tags
}


# module "irsa_actions_runner" {
#   source                  = "./irsa"
#   cluster_name            = module.eks.cluster_id
#   cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
#   policy_string = templatefile(
#     "./iam_policy_templates/actions-runner.tpl",
#     {
#       ....
#     }
#   )
#   namespace       = "actions-runner"
#   service_account = "actions-runner"
#   tags            = local.tags
# }

### Secrets Manager Secrets with assumable IAM Roles 



### Public GPG key

resource "local_file" "ksops_pub_asc" {
  content  = gpg_private_key.ksops_key.public_key
  filename = "${path.module}/output/ksops_pub.asc"
}


resource "local_file" "ksops_priv_asc" {
  content  = gpg_private_key.ksops_key.private_key
  filename = "${path.module}/output/ksops_priv.asc"
}

### Variable outputs:


resource "local_file" "vars" {
  content  = <<EOF
git_repo__url=${var.git_repo_url}
git_repo__target_revision=${var.git_repo_target_revision}
vpc_id=${module.vpc.vpc_id}
aws_region=${var.region}
cluster_name=${var.cluster_name}
role_arn__cluster_autoscaler=${module.irsa_cluster_autoscaler.role_arn}
role_arn__rok_tools=${module.irsa_rok_tools.role_arn}
sops__pgp_fingerprint=${gpg_private_key.ksops_key.fingerprint}
sensitive__rok_tools__gcr_json_key=${var.gcr_json_key}
sensitive__argocd__https_username="token"
sensitive__argocd__https_password=${var.argocd_github_token}
sensitive__argocd__sops_ksops_gpg_key_private__base64=${base64encode(gpg_private_key.ksops_key.private_key)}
sensitive__actions_runner_controller__github_app_id=${var.actions_app_id}
sensitive__actions_runner_controller__github_app_installation_id=${var.actions_app_installation_id}
sensitive__actions_runner_controller__github_app_private_key=${var.actions_app_private_key}
sensitive__actions_runner_controller__github_app_private_key__base64=${base64encode(var.actions_app_private_key)}
sensitive__actions_runner_controller__github_token=${var.actions_token}
DEX_DEFAULT_USER_PWHASH=bGludXhoaW50LmNvbQo=
OIDC_CLIENT_ID=123456
OIDC_CLIENT_SECRET=789012
  EOF
  filename = "${path.module}/output/vars.env"
}

# NOTE, since we are explicitly telling terraform not to manage the aws-auth ConfigMap, we have to create it here and then use kubectl apply afterwards.
# Note in particular that without the "system:node:{{EC2PrivateDNSName}}", nodes will not be able to join the cluster!  See https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html

resource "local_file" "aws_auth" {
  content  = <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - "rolearn": ${module.eks.worker_iam_role_arn}
      "username": "system:node:{{EC2PrivateDNSName}}"
      "groups":
      - "system:bootstrappers"
      - "system:nodes"
    - rolearn: ${data.aws_caller_identity.current.arn}
      username: default-master-role
      groups:
      - system:masters
    - rolearn: ${var.additional_kubernetes_admin_role_arn}
      username: additional-master
      groups:
      - system:masters
  mapUsers: |
    - userarn: ${data.aws_caller_identity.current.arn}
      username: default-master-user
      groups:
      - system:masters
  EOF
  filename = "${path.module}/output/aws-auth.yaml"
}


