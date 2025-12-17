resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

resource "null_resource" "enable_control_tower_baseline" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOT
set -euo pipefail

REGION="${var.control_tower_region}"
OU_ARN="${aws_organizations_organizational_unit.this.arn}"

# Get Baseline ARNs
BASELINE_INFO=$(aws controltower list-baselines --region $REGION)
CT_BASELINE_ARN=$(echo "$BASELINE_INFO" | jq -r '.baselines[] | select(.name=="AWSControlTowerBaseline") | .arn')
IDENTITY_CENTER_BASELINE_ARN=$(echo "$BASELINE_INFO" | jq -r '.baselines[] | select(.name=="IdentityCenterBaseline") | .arn')

# Get enabled Identity Center baseline (if any)
ENABLED_BASELINE_INFO=$(aws controltower list-enabled-baselines --region $REGION)
ENABLED_IDENTITY_CENTER_ARN=$(echo "$ENABLED_BASELINE_INFO" | jq -r --arg b "$IDENTITY_CENTER_BASELINE_ARN" '.enabledBaselines[] | select(.baselineIdentifier==$b) | .arn // empty')

PARAMS=""
if [ -n "$ENABLED_IDENTITY_CENTER_ARN" ]; then
  PARAMS="--parameters ParameterKey=IdentityCenterEnabledBaselineArn,ParameterValue=$ENABLED_IDENTITY_CENTER_ARN"
fi

# Check if baseline is already enabled
IS_ALREADY_ENABLED=$(echo "$ENABLED_BASELINE_INFO" \
  | jq -e --arg target "$OU_ARN" --arg baseline "$CT_BASELINE_ARN" \
  '.enabledBaselines[] | select(.targetIdentifier == $target and .baselineIdentifier == $baseline)' > /dev/null && echo "yes" || echo "no")

if [ "$IS_ALREADY_ENABLED" = "no" ]; then
  echo "Baseline not yet enabled, enabling..."
  aws controltower enable-baseline \
    --region $REGION \
    --baseline-identifier "$CT_BASELINE_ARN" \
    --baseline-version ${var.control_tower_baseline_version} \
    --target-identifier "$OU_ARN" \
    $PARAMS
else
  echo "Baseline is already enabled on $OU_ARN. Proceeding to poll status..."
fi

# Poll for baseline status
for i in {1..30}; do
  STATUS=$(aws controltower list-enabled-baselines --region $REGION \
    | jq -r --arg target "$OU_ARN" --arg baseline "$CT_BASELINE_ARN" \
    '.enabledBaselines[] | select(.targetIdentifier == $target and .baselineIdentifier == $baseline) | .statusSummary.status')

  echo "Current baseline status for $OU_ARN: $STATUS"

  if [ "$STATUS" == "SUCCEEDED" ]; then
    echo "Baseline successfully registered."
    exit 0
  elif [ "$STATUS" == "FAILED" ]; then
    echo "Baseline registration failed."
    exit 1
  elif [ "$STATUS" == "UNDER_CHANGE" ]; then
    echo "Baseline is still being applied..."
  fi

  sleep 10
done

echo "Timeout: OU baseline registration did not complete in time."
exit 1
EOT
  }

  depends_on = [aws_organizations_organizational_unit.this]
}
