data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws
  external_id = var.databricks_account_id
}

resource "aws_iam_role" "cross_account" {
  name               = "${local.prefix}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
}

data "databricks_aws_crossaccount_policy" "this" {
  provider   = databricks.mws
}

resource "aws_iam_role_policy" "this" {
  name   = "${local.prefix}-policy"
  role   = aws_iam_role.cross_account.id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

# There is a race condition between the creation of the cross-account IAM role (policy) and the registering
# the IAM role (policy) with Databricks, where Databricks does not "see" the IAM role (policy) even though Terraform
# believes it is created. We do not know the exact reason (e.g. if AWS reports the creation too early,
# if Databricks does not wait long enough, etc.). To solve the race condition, we add a short sleep in between.
resource "time_sleep" "wait_for_aws_iam_role_policy" {
  depends_on = [aws_iam_role_policy.this]

  create_duration = "10s"
}

resource "databricks_mws_credentials" "this" {
  provider   = databricks.mws
  depends_on = [time_sleep.wait_for_aws_iam_role_policy] // See comment above

  account_id       = var.databricks_account_id
  role_arn         = aws_iam_role.cross_account.arn
  credentials_name = "${local.prefix}-creds"
}
