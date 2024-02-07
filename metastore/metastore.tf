resource "databricks_metastore" "this" {
  provider      = databricks.workspace
  name          = var.metastore_name
  storage_root  = "s3://${aws_s3_bucket.metastore.id}"
  force_destroy = true
}

# There is a race condition between the creation of the data access IAM role and the registering
# the IAM role with Databricks, where Databricks does not "see" the IAM role even though Terraform
# believes it is created. We do not know the exact reason (e.g. if AWS reports the creation too early,
# if Databricks does not wait long enough, etc.). To solve the race condition, we add a short sleep in between.
resource "time_sleep" "wait_for_aws_iam_role" {
  depends_on = [aws_iam_role.metastore_data_access]

  create_duration = "15s"
}

resource "databricks_metastore_data_access" "this" {
  provider   = databricks.workspace
  depends_on = [time_sleep.wait_for_aws_iam_role]

  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.metastore_data_access.name
  aws_iam_role {
    role_arn = aws_iam_role.metastore_data_access.arn
  }
  is_default = true
  force_destroy = true
}
