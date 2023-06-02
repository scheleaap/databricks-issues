# Example of ...

## Steps to reproduce

1. Copy the metastore ID of a metastore in the region you want to deploy to. (Note: the metastore will not be affected; it's only needed to attach to the workspace.)
2. Copy [terraform.tfvars.example](terraform.tfvars.example) to `terraform.tfvars` and fill out all the values.
3. Run `terraform apply`.
4. Search for "TRIGGER" in the code and change any of the values.
5. Run `terraform plan` to see how the `databricks_mws_permission_assignment` resource will be recreated.
