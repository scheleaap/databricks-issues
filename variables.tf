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

variable "customer_id" {
  description = "The ID of the customer"
  type        = string
  default     = "test-customer"
}

variable "metastore_id" {
  description = "The ID of an existing metastore"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block to use for the VPC"
  type        = string
  default     = "10.0.0.0/23"
}

variable "workspace_name" {
  description = "The name of the workspace"
  type        = string
  default     = "issue-2382"
}
