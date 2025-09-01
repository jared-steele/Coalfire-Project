# backend-bootstrap/main.tf
terraform {
  backend "local" {}
}

terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
        }
    }
}


provider "aws" {
    region = local.region
}

#The bucket
resource "aws_s3_bucket" "terraform_state" {
    bucket = local.coalfire_project

    lifecycle {
      prevent_destroy = true
    }
  
}

#Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

#Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

#Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

#Create dynamodb table to Lock state file to prevent concurrent operations
resource "aws_dynamodb_table" "terraform_locks" {
    name = local.coalfire_project
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}