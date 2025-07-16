resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

resource "null_resource" "enable_control_tower_baseline" {
  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
set -euo pipefail

REGION="${var.control_tower_region}"

# Get Baseline ARNs
BASELINE_INFO=$(aws controltower list-baselines --region $REGION)
CT_BASELINE_ARN=$(echo $BASELINE_INFO | jq -r '.baselines[] | select(.name=="AWSControlTowerBaseline") | .arn')
IDENTITY_CENTER_BASELINE_ARN=$(echo $BASELINE_INFO | jq -r '.baselines[] | select(.name=="IdentityCenterBaseline") | .arn')

# Get enabled Identity Center baseline (if any)
ENABLED_BASELINE_INFO=$(aws controltower list-enabled-baselines --region $REGION)
ENABLED_IDENTITY_CENTER_ARN=$(echo $ENABLED_BASELINE_INFO | jq -r --arg b "$IDENTITY_CENTER_BASELINE_ARN" '.enabledBaselines[] | select(.baselineIdentifier==$b) | .arn // empty')

PARAMS=""
if [ -n "$ENABLED_IDENTITY_CENTER_ARN" ]; then
  PARAMS="--parameters ParameterKey=IdentityCenterEnabledBaselineArn,ParameterValue=$ENABLED_IDENTITY_CENTER_ARN"
fi

aws controltower enable-baseline \
  --region $REGION \
  --baseline-identifier "$CT_BASELINE_ARN" \
  --baseline-version ${var.control_tower_baseline_version} \
  --target-identifier "${aws_organizations_organizational_unit.this.arn}" \
  $PARAMS
EOT
  }

  depends_on = [aws_organizations_organizational_unit.this]
}