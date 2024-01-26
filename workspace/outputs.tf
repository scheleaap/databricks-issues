output "id" {
  # See https://kb.databricks.com/en_US/administration/find-your-workspace-id
  value = databricks_mws_workspaces.this.workspace_id
}

output "url" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}
