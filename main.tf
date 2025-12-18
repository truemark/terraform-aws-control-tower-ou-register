# Create the Organizational Unit
resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

# Data source to list available Control Tower baselines
data "aws_controltower_baselines" "available" {
  region = var.control_tower_region
}

# Find the AWSControlTowerBaseline ARN
locals {
  ct_baseline_arn = [
    for baseline in data.aws_controltower_baselines.available.baselines :
    baseline.arn if baseline.name == "AWSControlTowerBaseline"
  ][0]

  identity_center_baseline_arn = [
    for baseline in data.aws_controltower_baselines.available.baselines :
    baseline.arn if baseline.name == "IdentityCenterBaseline"
  ][0]
}

# Data source to check for enabled Identity Center baseline
data "aws_controltower_enabled_baselines" "current" {
  region = var.control_tower_region
}

# Find if Identity Center baseline is already enabled
locals {
  enabled_identity_center_baseline = try([
    for enabled in data.aws_controltower_enabled_baselines.current.enabled_baselines :
    enabled.arn if enabled.baseline_identifier == local.identity_center_baseline_arn
  ][0], null)
}

# Enable Control Tower baseline for the OU
resource "aws_controltower_baseline" "this" {
  baseline_identifier = local.ct_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.this.arn
  region              = var.control_tower_region

  # Include Identity Center baseline parameter if it's enabled
  dynamic "parameters" {
    for_each = local.enabled_identity_center_baseline != null ? [1] : []
    content {
      key   = "IdentityCenterEnabledBaselineArn"
      value = local.enabled_identity_center_baseline
    }
  }

  tags = var.tags
}
