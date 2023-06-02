# [ISSUE] Creating `databricks_entitlements` fails if all entitlements are false

If you create a `databricks_entitlements` with all entitlements set to false (`allow_cluster_create`, `allow_instance_pool_create`, `databricks_sql_access`, `workspace_access`)
Terraform will fail with the following error:
```
╷
│ Error: cannot create entitlements: Error in performing the patch operation on group resource.
│ 
│   with databricks_entitlements.this,
│   on main.tf line 44, in resource "databricks_entitlements" "this":
│   44: resource "databricks_entitlements" "this" {
│ 
╵
```

### Configuration

A fully-functioning minimal example that reproduces the problem, with steps that describe how to reproduce can be found here:
https://github.com/scheleaap/databricks-issues/tree/false-entitlements

The most relevant code:

```hcl
resource "databricks_entitlements" "this" {
  provider = databricks.workspace
  depends_on = [databricks_mws_permission_assignment.this]

  group_id                   = databricks_group.this.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = false
  workspace_access           = false
}
```

### Expected Behavior

The entitlements are set to false, regardless of their previous value.

### Actual Behavior

The provider returns an error and the original entitlements values remain.

```
╷
│ Error: cannot create entitlements: Error in performing the patch operation on group resource.
│ 
│   with databricks_entitlements.this,
│   on main.tf line 44, in resource "databricks_entitlements" "this":
│   44: resource "databricks_entitlements" "this" {
│ 
╵
```

### Steps to Reproduce

A fully-functioning minimal example that reproduces the problem, with steps that describe how to reproduce can be found here:
https://github.com/scheleaap/databricks-issues/tree/false-entitlements

### Terraform and provider versions

```
Terraform v1.4.0
on linux_amd64
+ provider registry.terraform.io/databricks/databricks v1.18.0
+ provider registry.terraform.io/hashicorp/aws v4.67.0
+ provider registry.terraform.io/hashicorp/time v0.9.1

Your version of Terraform is out of date! The latest version
is 1.4.6. You can update by downloading from https://www.terraform.io/downloads.html
```

### Debug Output

https://github.com/scheleaap/databricks-issues/blob/false-entitlements/tf-debug.log
