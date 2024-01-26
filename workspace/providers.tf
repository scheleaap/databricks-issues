terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    databricks = {
      source                = "databricks/databricks"
      version               = "1.35"
      configuration_aliases = [databricks.mws]
    }
  }
}
