# Completely unrelated changes trigger replacement of `databricks_mws_permission_assignment` when using `databricks_service_principal` data source in another module

Some changes completely unrelated to workspace permissions of service principals
will trigger the replacement of [`databricks_mws_permission_assignment`](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_permission_assignment) resources 
if they depend on a [`databricks_service_principal`](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/service_principal) data source
and the data source is located in a submodule.

The changes seem completely unrelated to adding service principals to a workspace.
Here are some random changes that will trigger the behavior:
* Changing the value of the `force_destroy` or `tags` fields of the `aws_s3_bucket` resource of the workspace root bucket
* Changing the value of the `aws_s3_bucket_acl` resource belonging to the workspace root bucket
* Changing the value of the `allow_cluster_create` field of the `databricks_service_principal` resource

Whenever the behavior is triggered, Terraform will:
* Update whatever resource you want to change
* Remove the service principal from the workspace and add it again

This poses a problem for us, because when a service principal is removed & re-added, its On-Behalf-Of token is replaced as well, which is used by other applications.
What this mean is that many seemingly harmless infrastructure changes currently break out applications using OBO tokens.

It seems that this behavior does not happen when the `databricks_service_principal` data source is moved into the top-level module (i.e. [main.tf](main.tf)).

Example output:
```
Terraform will perform the following actions:

(...)

  # module.workspace_principals_access.data.databricks_service_principal.this will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "databricks_service_principal" "this" {
      + active         = (known after apply)
      + application_id = "efd9a144-8770-48e0-9ddf-56f00d82d551"
      + display_name   = (known after apply)
      + external_id    = (known after apply)
      + home           = (known after apply)
      + id             = (known after apply)
      + repos          = (known after apply)
      + sp_id          = (known after apply)
    }

  # module.workspace_principals_access.databricks_mws_permission_assignment.service_principal must be replaced
-/+ resource "databricks_mws_permission_assignment" "service_principal" {
      ~ id           = "7986280547591627|7940610747815743" -> (known after apply)
      ~ principal_id = 7940610747815743 # forces replacement -> (known after apply)
        # (2 unchanged attributes hidden)
    }
```

### Configuration

A fully-functioning minimal example that reproduces the problem, with steps that describe how to reproduce can be found here:
https://github.com/scheleaap/databricks-issues/tree/sp-data-source-workspace-access

The most relevant code:

**main.tf:**
```hcl
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
  allow_cluster_create = false
}

module "workspace_principals_access" {
  source = "../modules/workspace_principals_access"
  providers = {
    databricks.mws       = databricks.mws
  }
  depends_on = [databricks_metastore_assignment.this, databricks_service_principal.jobs]

  workspace_id                            = module.workspace.id
  service_principal_application_id       = databricks_service_principal.jobs.application_id
}
```

**workspace_principals_assigment/main.tf:**
```hcl
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
```

### Expected Behavior

If we change the tags on the workspace root bucket, only the tags are updated.

### Actual Behavior

If we change the tags on the workspace root bucket, the tags are updated *and* the resource `module.workspace_principals_access.databricks_mws_permission_assignment.service_principal` is recreated.

### Steps to Reproduce

A fully-functioning minimal example that reproduces the problem, with steps that describe how to reproduce can be found here:
https://github.com/scheleaap/databricks-issues/tree/sp-data-source-workspace-access

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

https://github.com/scheleaap/databricks-issues/blob/sp-data-source-workspace-access/tf-debug.log
