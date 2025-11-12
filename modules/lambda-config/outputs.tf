# Module Parameters
# Define project variables for usability of other modules

output "security_group_id" {
  value = aws_security_group.lambda_security_group.id
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
