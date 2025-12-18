# Terraform Module: AWS Control Tower OU Registration

This Terraform module creates an AWS Organizations Organizational Unit (OU) and automatically registers it with AWS Control Tower by enabling the `AWSControlTowerBaseline` using the native `aws_controltower_baseline` Terraform resource. It also optionally links to the `IdentityCenterBaseline` if already enabled.

The module uses Terraform's native Control Tower resources for idempotent, reliable baseline management with built-in state tracking.

---

## Features

- Creates a new Organizational Unit (OU)
- Enables AWS Control Tower baseline for the OU using native Terraform resources
- Supports Identity Center baseline integration if enabled
- Native Terraform state management with built-in timeouts (30m default)
- Fully idempotent - safe to re-run

---

## Usage

### Basic Usage

```hcl
module "sandbox_ou" {
  source                         = "./modules/controltower_ou"

  name                           = "Sandbox"
  parent_id                      = "r-abc123"                   # Root or parent OU ID
  control_tower_region           = "us-east-1"                  # Region where Control Tower is deployed
  control_tower_baseline_version = "4.0"                        # Optional version override
}
```

### Accessing Account IDs from the OU

```hcl
module "sandbox_ou" {
  source               = "./modules/controltower_ou"
  name                 = "Sandbox"
  parent_id            = "ou-xxxx-xxxxxxxx"
  control_tower_region = "us-east-1"
}

# Access account IDs from the created OU
locals {
  sandbox_account_ids = concat(module.sandbox_ou.ou_accounts[*].id)
}
```

---

## Input Variables

| Name                         | Description                                                   | Type         | Default | Required |
|------------------------------|---------------------------------------------------------------|--------------|---------|----------|
| `name`                       | Name of the OU to create                                      | string       | —       | ✅ Yes   |
| `parent_id`                  | ID of the parent OU or Root (e.g., `r-xxxx`)                  | string       | —       | ✅ Yes   |
| `control_tower_region`       | Region where Control Tower is deployed (e.g., `us-east-1`)    | string       | —       | ✅ Yes   |
| `control_tower_baseline_version` | Version of AWSControlTowerBaseline to enable             | string       | `"4.0"` | ❌ No    |
| `baseline_arn`               | ARN of the AWS Control Tower baseline (auto-constructed if not provided) | string | `null` | ❌ No |
| `identity_center_baseline_arn` | ARN of an enabled Identity Center baseline (enabledBaseline ARN) | string | `null` | ❌ No |
| `tags`                       | Tags to apply to the Control Tower baseline                   | map(string)  | `{}`    | ❌ No    |

---

## Outputs

| Name                            | Description                                              |
|---------------------------------|----------------------------------------------------------|
| `ou_id`                         | The ID of the created OU                                 |
| `ou_arn`                        | The ARN of the created OU                                |
| `ou_name`                       | The name of the created OU                               |
| `ou_accounts`                   | List of accounts in the Organizational Unit              |
| `baseline_arn`                  | The ARN of the enabled Control Tower baseline            |
| `baseline_operation_identifier` | The operation identifier (UUID) of baseline enablement   |

---

## Behavior

- **Native Terraform Resource:** Uses `aws_controltower_baseline` resource for full Terraform state management
- **Baseline ARN Construction:** Automatically constructs the Control Tower baseline ARN based on the region (can be overridden)
- **Identity Center Integration:** Optionally links to Identity Center baseline if the enabled baseline ARN is provided
- **Built-in Timeouts:** Default 30-minute timeout for create/update/delete operations
- **Idempotent:** Safe to re-apply without side effects

---

## Permissions Required

Ensure the IAM role or user running Terraform has:

- `organizations:CreateOrganizationalUnit`
- `organizations:DescribeOrganizationalUnit`
- `controltower:ListBaselines`
- `controltower:ListEnabledBaselines`
- `controltower:EnableBaseline`
- `controltower:GetBaseline`
- `controltower:UpdateEnabledBaseline`
- `controltower:DisableBaseline`

---

## Example Use Case

Use this module to dynamically register any new OU as part of your AWS account provisioning pipelines, bootstrapped with Control Tower governance.

---

## Notes

- **No external dependencies:** No longer requires AWS CLI or `jq`
- Uses native Terraform AWS provider resources (requires AWS provider >= 6.0)
- Fully manages baseline lifecycle through Terraform state
- Only registers `AWSControlTowerBaseline`. Additional baseline support may be added as needed.

---

## Related AWS Docs

- [Control Tower API Reference](https://docs.aws.amazon.com/controltower/latest/APIReference/)
- [Control Tower Baseline Concepts](https://docs.aws.amazon.com/controltower/latest/userguide/baselines.html)

---
