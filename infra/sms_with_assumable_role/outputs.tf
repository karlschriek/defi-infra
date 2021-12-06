output "role_arn" {
  value = module.iam_assumable_role.iam_role_arn
}


output "secret_name" {
  value = local.secret_name
}