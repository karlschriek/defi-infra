
locals {

  role_name = "${var.cluster_name}_irsa_${var.namespace}_${var.service_account}"
}
## create an IAM Role for Serice Accounts, bind all "oidc_fully_qualified_subjects" to it and bind the IAM policy that allows reading from aws_secretsmanager_secret.secret
module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7"

  create_role                   = true
  role_name                     = local.role_name
  tags                          = var.tags
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = flatten([module.iam_policy.arn, var.additional_role_policy_arns])
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
}


## create a policy that allows an IAM role to access the secret
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.7"

  name   = "${local.role_name}-policy"
  policy = var.policy_string

  tags   = var.tags
}


