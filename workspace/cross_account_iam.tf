# Creates a 'cross-account' IAM role that gives Databricks' AWS account access to our AWS account.
#
# # References
#
# Setting up the cross account IAM role:
# * https://docs.databricks.com/administration-guide/cloud-configurations/aws/iam-role.html
# * https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace#cross-account-iam-role
#
# Allowing the cross-account IAM role to pass on to other AWS services in order to support instance profiles:
# * https://docs.databricks.com/aws/iam/instance-profile-tutorial.html#step-3-modify-the-iam-role-for-the-databricks-workspace
# * https://docs.databricks.com/aws/iam/add-instance-profile-workspace-role.html#add-the-s3-iam-role-to-the-ec2-policy
# * https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/instance_profile
# (Note that the documentation and the Terraform examples use S3 instance profiles as an example, but this can (should)
# be generalized to any instance profiles.)


# Generate a trust policy that allows the Databricks AWS account to assume the cross account IAM role (but only on
# behalf of our Databricks account ID).
data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws
  external_id = var.databricks_account_id
}

resource "aws_iam_role" "cross_account" {
  name               = "${local.prefix}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags               = local.module_tags
}

# Generate a policy that grants:
# 1. Permissions required by the Databricks control plane, documented here:
#    https://docs.databricks.com/administration-guide/cloud-configurations/aws/iam-role.html.
# 2. Permissions to pass the Auto Loader IAM role to AWS services (in our case, EC2).
#    This corresponds to "Step 3: Modify the IAM role for the Databricks workspace" of
#    https://docs.databricks.com/aws/iam/instance-profile-tutorial.html#step-3-modify-the-iam-role-for-the-databricks-workspace.
data "databricks_aws_crossaccount_policy" "this" {
  provider   = databricks.mws
  pass_roles = []
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

  role_arn         = aws_iam_role.cross_account.arn
  credentials_name = "${local.prefix}-creds"
  # account_id was recently deprecated
  # account_id       = var.databricks_account_id
}
