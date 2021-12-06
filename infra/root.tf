terraform {
  required_version = "1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
      #configuration_aliases = [aws.root_hosted_zone]
    }
    
    gpg = {
      source = "Olivr/gpg"
      version = "0.2.0"
    }

  }

  backend "s3" {
    # see https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration

    ## NOTE, we have to two options for setting the backend:

    ## 1. Hardcoded here as follows:
    # bucket = "terraform-state-files-409688176173"
    # key    = "test-path"
    # region = "us-east-2"
    # role_arn = "arn:aws:iam::409688176173:role/terraform-ci"

    ## 2. Or, to make it configurable we leave this block blank and set the params when calling "terraform init", e.g.
    # terraform init \
    # -backend-config="bucket=${TFSTATE_BUCKET}" \
    # -backend-config="key=${TFSTATE_KEY}" \
    # -backend-config="region=${TFSTATE_REGION}" \
    # -backend-config="role_arn=${TFSTATE_ROLE_ARN}" 

  }

}
