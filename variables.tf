variable "name" {
  description = "Name of the Organizational Unit"
  type        = string
}

variable "parent_id" {
  description = "ID of the parent Organizational Unit or Root"
  type        = string
}

variable "control_tower_region" {
  description = "Region where Control Tower is deployed (e.g., us-east-1)"
  type        = string
}

variable "control_tower_baseline_version" {
  description = "Control Tower baseline version to apply (e.g., 4.0)"
  type        = string
  default     = "4.0"
}

variable "baseline_arn" {
  description = "ARN of the AWS Control Tower baseline. If not provided, will be constructed as arn:aws:controltower:{region}::baseline/AWSControlTowerBaseline"
  type        = string
  default     = null
}

variable "identity_center_baseline_arn" {
  description = "ARN of an enabled Identity Center baseline (if applicable). This is the enabledBaseline ARN, not the baseline ARN."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the Control Tower baseline"
  type        = map(string)
  default     = {}
}
