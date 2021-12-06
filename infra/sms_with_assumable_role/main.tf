
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


locals {

  secret_name   = "${var.cluster_name}/${var.namespace}" #we use a convention here to only create one secret per namespace. Secret entries are kept in key: value pairs in "secret_string"
  secret_string = jsonencode(var.secret_map)
  aws_region    = data.aws_region.current.name
  aws_account   = data.aws_caller_identity.current.account_id
  role_name     = "${var.cluster_name}_${var.external_secret_role_name_prefix}_${var.namespace}"

}


## create an external secret
resource "aws_secretsmanager_secret" "secret" {
  name = local.secret_name
  tags = var.tags
  recovery_window_in_days = 0 #in order to immediately delete secrets with terraform destroy
}

## populate the external secret with values.

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = local.secret_string
}


## create a policy that allows an IAM role to access the secret
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.7"

  name   = "${local.role_name}-policy"
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetSecretValue",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:DescribeSecret"
        ],
        "Resource": "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account}:secret:${local.secret_name}*"
    }
  ]
}
   EOF
  tags   = var.tags
}


module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.7"

  trusted_role_arns       = var.trusted_role_arns
  create_role             = true
  role_name               = local.role_name
  role_requires_mfa       = false
  custom_role_policy_arns = [module.iam_policy.arn]
}

