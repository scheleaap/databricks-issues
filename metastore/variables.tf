variable "metastore_name" {
  description = "The name of the metastore"
  type        = string
}

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
}

locals {
  prefix    = "ap-${var.metastore_name}"
  s3_prefix = "ri-${local.prefix}"
}
