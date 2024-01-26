# When Terraform tries to create a new workspace, this error message often appears:
#
# cannot read mws workspaces: cannot read token: Unauthorized
#
# Terraform needs to configure the cross-account role to be able to create new workspaces in the AWS account before it
# creates a new workspace. However, when the work creation happens, authorization fails, despite Terraform's belief the
# cross-account role already exists. We need to wait a bit until the cross-account role is created.
resource "time_sleep" "wait_for_databricks_mws_credentials" {
  depends_on = [databricks_mws_credentials.this]

  create_duration = "15s"
}

resource "databricks_mws_workspaces" "this" {
  provider   = databricks.mws
  depends_on = [time_sleep.wait_for_databricks_mws_credentials]

  account_id      = var.databricks_account_id
  aws_region      = var.region
  workspace_name  = local.prefix
  deployment_name = local.prefix

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Managed by Terraform"
  }
}
