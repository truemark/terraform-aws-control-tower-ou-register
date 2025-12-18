output "ou_id" {
  description = "The ID of the created Organizational Unit"
  value       = aws_organizations_organizational_unit.this.id
}

output "ou_arn" {
  description = "The ARN of the created Organizational Unit"
  value       = aws_organizations_organizational_unit.this.arn
}

output "ou_name" {
  description = "The name of the created Organizational Unit"
  value       = aws_organizations_organizational_unit.this.name
}

output "ou_accounts" {
  description = "List of accounts in the Organizational Unit"
  value       = aws_organizations_organizational_unit.this.accounts
}

output "baseline_arn" {
  description = "The ARN of the enabled Control Tower baseline"
  value       = aws_controltower_baseline.this.arn
}

output "baseline_operation_identifier" {
  description = "The operation identifier (UUID) of the baseline enablement"
  value       = aws_controltower_baseline.this.operation_identifier
}
