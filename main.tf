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

resource "databricks_service_principal" "jobs" {
  provider   = databricks.mws
  depends_on = [time_sleep.wait_for_workspace]

  display_name         = "${var.customer_id}-jobs"
  allow_cluster_create = false // TRIGGER: Change to true
}

// Note: The data source used by the workspace_principals_access module is not needed and we could reference the
// resource directly in this example. However, it is here because this is a very simplified version of our production
// code.

module "workspace_principals_access" {
  source = "./workspace_principals_access"
  providers = {
    databricks.mws = databricks.mws
  }
  depends_on = [databricks_metastore_assignment.this, databricks_service_principal.jobs]

  workspace_id                     = module.workspace.id
  service_principal_application_id = databricks_service_principal.jobs.application_id
}

output "workspace_url" {
  value = module.workspace.url
}
