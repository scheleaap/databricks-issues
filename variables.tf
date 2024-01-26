variable "aws_account_id" {
  description = "The AWS Account ID where the module will be deployed"
  type        = string
}

variable "region" {
  description = "The AWS region where the module will be deployed"
  type        = string
}

variable "databricks_account_id" {
  description = "The Databricks Account ID"
  type        = string
  default     = "4c36a1c7-9b03-4cea-9d2e-4b9cdeef721b"
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
  default     = "10.0.0.0/23"
}

variable "metastore_name" {
  description = "The name of the metastore"
  type        = string
  default     = "issue-3157"
}

variable "workspace_name" {
  description = "The name of the workspace"
  type        = string
  default     = "issue-3157"
}
