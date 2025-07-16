output "ou_id" {
  value = aws_organizations_organizational_unit.this.id
}

output "ou_arn" {
  value = aws_organizations_organizational_unit.this.arn
}

output "ou_name" {
  value = aws_organizations_organizational_unit.this.name
}