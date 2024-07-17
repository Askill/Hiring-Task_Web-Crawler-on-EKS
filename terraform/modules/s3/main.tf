#############################
# VARs
#############################

locals {
  cluster_name = "${var.project_name}-${var.stage}-eks"
  vpc_name     = "${var.project_name}-${var.stage}-vpc"
}

#############################
# Providers
#############################

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.stage
      Project     = "web-crawler-on-eks"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "delete_after_3_days" {
  bucket = aws_s3_bucket.app_cache.id

  # this rule assumes the crawler runs at least once a day, 
  # allowing for one missed day or time zone related issues, 
  # the expiration is set to 3 days
  rule {
    id     = "delete-after-3-days"
    status = "Enabled"
    expiration {
      days = 3
    }
  }
}
resource "aws_s3_bucket" "app_cache" {
  bucket = "${var.project_name}-${var.stage}-cache"

  # I would not enable this in a client setting, 
  # this is purely for convinience for this specific hiring task
  force_destroy = true
}