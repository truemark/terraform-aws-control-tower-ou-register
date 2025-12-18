# Create the Organizational Unit
resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

# Discover Control Tower baseline ARNs using external data source (only if baseline_arn not provided)
data "external" "baselines" {
  count = var.baseline_arn == null ? 1 : 0

  program = ["bash", "-c", <<-EOT
    set -e
    BASELINE_INFO=$(aws controltower list-baselines --region ${var.control_tower_region})
    CT_BASELINE_ARN=$(echo "$BASELINE_INFO" | jq -r '.baselines[] | select(.name=="AWSControlTowerBaseline") | .arn')

    ENABLED_BASELINE_INFO=$(aws controltower list-enabled-baselines --region ${var.control_tower_region})
    IDENTITY_CENTER_BASELINE_ARN=$(echo "$BASELINE_INFO" | jq -r '.baselines[] | select(.name=="IdentityCenterBaseline") | .arn')
    ENABLED_IDENTITY_CENTER_ARN=$(echo "$ENABLED_BASELINE_INFO" | jq -r --arg b "$IDENTITY_CENTER_BASELINE_ARN" '.enabledBaselines[] | select(.baselineIdentifier==$b) | .arn // empty')

    jq -n \
      --arg ct_arn "$CT_BASELINE_ARN" \
      --arg ic_arn "$ENABLED_IDENTITY_CENTER_ARN" \
      '{"ct_baseline_arn": $ct_arn, "identity_center_enabled_arn": $ic_arn}'
  EOT
  ]
}

# Use discovered or provided baseline ARNs
locals {
  ct_baseline_arn = var.baseline_arn != null ? var.baseline_arn : data.external.baselines[0].result.ct_baseline_arn
  identity_center_baseline_arn = var.identity_center_baseline_arn != null ? var.identity_center_baseline_arn : (
    var.baseline_arn == null && data.external.baselines[0].result.identity_center_enabled_arn != "" ? data.external.baselines[0].result.identity_center_enabled_arn : null
  )
}

# Enable Control Tower baseline for the OU
resource "aws_controltower_baseline" "this" {
  baseline_identifier = local.ct_baseline_arn
  baseline_version    = var.control_tower_baseline_version
  target_identifier   = aws_organizations_organizational_unit.this.arn
  region              = var.control_tower_region

  # Include Identity Center baseline parameter if available
  dynamic "parameters" {
    for_each = local.identity_center_baseline_arn != null ? [1] : []
    content {
      key   = "IdentityCenterEnabledBaselineArn"
      value = local.identity_center_baseline_arn
    }
  }

  tags = var.tags
}
