variable "region" {
  description = "The AWS region where the module will be deployed"
  type        = string
}

variable "databricks_account_id" {
  description = "The Databricks Account ID"
  type        = string
}

variable "databricks_account_username" {
  description = "The username (i.e. e-mail address) you use to login to https://accounts.cloud.databricks.com/"
  type        = string
}

variable "databricks_account_password" {
  description = "The password you use to login to https://accounts.cloud.databricks.com/"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block to use for the VPC"
  type        = string
}

variable "workspace_name" {
  description = "The name of the workspace"
  type        = string
}

locals {
  prefix    = "ap-${var.workspace_name}"
  s3_prefix = "ri-${local.prefix}"
  module_tags = {
    WorkspaceName = var.workspace_name
  }
}
