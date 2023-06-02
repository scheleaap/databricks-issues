data "databricks_service_principal" "this" {
  provider = databricks.mws

  application_id = var.service_principal_application_id
}

resource "databricks_mws_permission_assignment" "service_principal" {
  provider = databricks.mws

  workspace_id = var.workspace_id
  principal_id = data.databricks_service_principal.this.id
  permissions  = ["USER"]
}
