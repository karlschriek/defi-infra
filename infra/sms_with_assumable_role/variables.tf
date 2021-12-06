variable "cluster_name" {
  type        = string
  description = "The name of the cluster where the ServiceAccount(s) that should be able to assume the IAM Role that can access the Secret Manager Secrets is found. This name will be used as part of the path where the Secret Manager Secret is stored"
}


variable "trusted_role_arns" {
  type        = list(string)
  description = "A list of ARNs of IAM roles that will be able to assume the IAM Role that is able to access the Secret Manager Secret"
}


variable "namespace" {
  type        = string
  description = "The name of the Namespace where the ServiceAccount(s) that should be able to assume the IAM Role that can access the Secret Manager Secrets is found. This name will be used as part of the path where the Secret Manager Secret is stored"

}

variable "secret_map" {
  type        = map(string)
  description = <<EOF
    A map of key:value pairs of the secret entries to be stored in Secrets Manager. For example:

    secret_map = {
        "key1": "123",
        "key2": "somevalue"
    }
    EOF
}

variable "tags" {
  type        = map(string)
  description = "Default tags that will be added to the AWS resources created in this module"
  default     = {}

}

variable "external_secret_role_name_prefix" {
  type        = string
  description = "A prefix to add to the name of the IAM role that will be created"

}



