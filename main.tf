# Create the Organizational Unit
resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

# Construct baseline ARN - AWS Control Tower baseline ARN is static per region
locals {
  ct_baseline_arn = var.baseline_arn != null ? var.baseline_arn : "arn:aws:controltower:${var.control_tower_region}::baseline/AWSControlTowerBaseline"
}

# Enable Control Tower baseline for the OU
resource "aws_controltower_baseline" "this" {
  baseline_identifier = local.ct_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.this.arn
  region              = var.control_tower_region

  # Include Identity Center baseline parameter if provided
  dynamic "parameters" {
    for_each = var.identity_center_baseline_arn != null ? [1] : []
    content {
      key   = "IdentityCenterEnabledBaselineArn"
      value = var.identity_center_baseline_arn
    }
  }

  tags = var.tags
}
