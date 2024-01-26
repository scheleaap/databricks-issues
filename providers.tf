terraform {
  required_version = ">= 1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.35"
    }
  }
}

provider "aws" {
  region = var.region
}

# Account-level provider for Databricks
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  username   = var.databricks_account_username
  password   = var.databricks_account_password
}

# Workspace-level providers for Databricks
provider "databricks" {
  alias = "workspace"
  host  = module.workspace.url
  token = module.workspace.token
}