resource "aws_s3_bucket" "root_storage" {
  bucket        = "${local.s3_prefix}-rootbucket"
  force_destroy = true // TRIGGER: Change to false
  tags = {
    Name = "${local.s3_prefix}-rootbucket" // TRIGGER: Change or remove
    # Foo = 123 // TRIGGER: Add
  }
}

resource "aws_s3_bucket_ownership_controls" "root_storage" {
  bucket = aws_s3_bucket.root_storage.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "root_storage" {
  bucket = aws_s3_bucket.root_storage.id
  versioning_configuration {
    status = "Disabled" // TRIGGER: Change to "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "root_storage" {
  bucket                  = aws_s3_bucket.root_storage.id
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage.bucket
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.root_storage]

  bucket = aws_s3_bucket.root_storage.id
  policy = data.databricks_aws_bucket_policy.this.json
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage.bucket
  storage_configuration_name = "${local.prefix}-storage"
}
