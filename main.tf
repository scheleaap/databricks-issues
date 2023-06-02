module "workspace" {
  source = "./workspace"
  providers = {
    databricks.mws = databricks.mws
  }

  region                      = var.region
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  workspace_name              = var.workspace_name
  vpc_cidr_block              = var.vpc_cidr_block
}

resource "time_sleep" "wait_for_workspace" {
  depends_on = [module.workspace]

  create_duration = "10s"
}

resource "databricks_metastore_assignment" "this" {
  provider   = databricks.workspace
  depends_on = [time_sleep.wait_for_workspace]

  workspace_id         = module.workspace.id
  metastore_id         = var.metastore_id
  default_catalog_name = "hive_metastore"
}

resource "databricks_group" "this" {
  provider     = databricks.mws
  display_name = var.customer_id
}

resource "databricks_mws_permission_assignment" "this" {
  provider   = databricks.mws
  depends_on = [databricks_metastore_assignment.this, databricks_group.this]

  workspace_id = module.workspace.id
  principal_id = databricks_group.this.id
  permissions  = ["USER"]
}

resource "databricks_entitlements" "this" {
  provider   = databricks.workspace
  depends_on = [databricks_mws_permission_assignment.this]

  group_id                   = databricks_group.this.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = false
  workspace_access           = false
}

output "workspace_url" {
  value = module.workspace.url
}
