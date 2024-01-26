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

resource "time_sleep" "wait_for_workspaces" {
  depends_on = [module.workspace]

  create_duration = "10s"
}

module "metastore" {
  source = "./metastore"
  providers = {
    databricks.workspace = databricks.workspace
  }
  depends_on = [time_sleep.wait_for_workspaces]

  metastore_name        = var.metastore_name
  aws_account_id        = var.aws_account_id
  region                = var.region
  databricks_account_id = "4c36a1c7-9b03-4cea-9d2e-4b9cdeef721b"
}

module "workspace_metastore_assignment" {
  source = "./workspace_metastore_assignment"
  providers = {
    databricks.workspace = databricks.workspace
  }
  depends_on = [time_sleep.wait_for_workspaces]

  metastore_id = module.metastore.metastore_id
  workspace_id = module.workspace.id
}
