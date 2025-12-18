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

variable "tags" {
  description = "Tags to apply to the Control Tower baseline"
  type        = map(string)
  default     = {}
}
