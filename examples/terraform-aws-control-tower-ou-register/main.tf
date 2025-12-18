terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "af-south-1"
}


module "ct_sandbox_ou" {
  source                         = "../../"
  name                           = "ControlTowerSandbox"
  parent_id                      = "<org_id>"
  control_tower_region           = "af-south-1"
  control_tower_baseline_version = "4.0"

  # Optional: Manually specify baseline ARN to avoid AWS CLI dependency
  # baseline_arn = "arn:aws:controltower:af-south-1::baseline/17BSJV3IGJ2QSGA2"
}
