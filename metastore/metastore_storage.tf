resource "aws_s3_bucket" "metastore" {
  bucket = "${local.s3_prefix}-metastore"
  tags = {
    Name = "${local.s3_prefix}-metastore"
  }
}

resource "aws_s3_bucket_ownership_controls" "metastore" {
  bucket = aws_s3_bucket.metastore.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "metastore" {
  bucket = aws_s3_bucket.metastore.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "metastore" {
  depends_on = [aws_s3_bucket.metastore]

  bucket                  = aws_s3_bucket.metastore.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "access_metastore_bucket" {
  name = "${local.prefix}-access-metastore-bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.prefix}-access-metastore-bucket"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          aws_s3_bucket.metastore.arn,
          "${aws_s3_bucket.metastore.arn}/*"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

locals {
  metastore_data_access_iam_role_name = "${local.prefix}-metastore-data-access"
}

data "aws_iam_policy_document" "assumerole_for_uc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  // See https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/${local.metastore_data_access_iam_role_name}",
      ]
    }
  }
}

resource "aws_iam_role" "metastore_data_access" {
  name                = local.metastore_data_access_iam_role_name
  assume_role_policy  = data.aws_iam_policy_document.assumerole_for_uc.json
  managed_policy_arns = [aws_iam_policy.access_metastore_bucket.arn]
}
