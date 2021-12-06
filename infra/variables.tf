
variable "cluster_name" {
  type        = string
  description = "A name of the Amazon EKS cluster"
}

# TODO this was temporarily deactivated to keep local development simpler
# variable "role_arn" {
#   type        = string
#   description = "The ARN of the role to assume when building the AWS infrastructure"

# }

variable "additional_kubernetes_admin_role_arn" {
  type        = string
  description = "An additional IAM Role ARN that will be added to the aws-auth ConfigMap as system:master"
}


variable "region" {
  type        = string
  description = "The AWS region within which the AWS infrastructure will be rolled out"

}

variable "argocd_github_token" {
  type        = string
  description = "A token with which to ArgoCD can can access to a private GitHub repo"
  sensitive   = true
}

variable "git_repo_url" {
  type        = string
  description = "The URL of the repository from which ArgoCD will be syncing"
}

variable "git_repo_target_revision" {
  type        = string
  description = "The target revision (branch/tag/commit) from which ArgoC will be syncing"
}

variable "cert_manager_email_user" {
  type        = string
  description = "cert-manager requires a email address to set up as the certificate owner. You should input your GSuite username, such as kschriek, here"
}

variable "cert_manager_email_domain" {
  type        = string
  description = "cert-manager requires a email address to set up as the certificate owner. You should probably input arrikto.com here"
  default     = "arrikto.com"
}


variable "actions_app_id" {
  type        = string
  default     = ""
  description = "TODO"
  sensitive   = true
}


variable "actions_app_installation_id" {
  type        = string
  default     = ""
  description = "TODO"
  sensitive   = true
}


variable "actions_app_private_key" {
  type        = string
  default     = ""
  description = "TODO"
  sensitive   = true
}


variable "actions_token" {
  type        = string
  default     = ""
  description = "TODO"
  sensitive   = true
}

variable "gcr_json_key" {
  type        = string
  default     = ""
  description = "TODO"
  sensitive   = true
}
