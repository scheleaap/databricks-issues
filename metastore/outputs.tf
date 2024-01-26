output "metastore_id" {
  description = "The ID of the created metastore"
  value       = databricks_metastore.this.id
}
