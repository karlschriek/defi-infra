variable "cluster_oidc_issuer_url" {
  type        = string
  description = "The OIDC issuer URL that corresponds to the cluster with the name 'var.cluster_name'. IRSA must have been enabled on this cluster"
}

variable "cluster_name" {
  type        = string
  description = "A name of the Amazon EKS cluster"
}



variable "additional_role_policy_arns" {
  type        = list(string)
  description = "A list of ARNs of policies that will additionally be attached to the IAM Role that is created for the Service Accounts"
  default     = []
}


variable "tags" {
  type        = map(string)
  description = "Default tags that will be added to the AWS resources created in this module"
  default     = {}

}

variable "policy_string" {
  type        = string
  description = "String representation of a policy that will be created and attached to the IAM Role"

}

variable "service_account" {
  type        = string
  description = <<EOF
  The name of the service account that will be allowed to assume the IAM Role
  EOF
}
variable "namespace" {
  type        = string
  description = "The namespace of the service account that will be allowed to assume the IAM Role"
}

