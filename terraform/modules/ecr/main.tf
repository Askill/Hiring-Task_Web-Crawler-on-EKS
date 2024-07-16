
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

resource "aws_ecr_repository" "optar" {
  name                 = "optar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "optar" {
  statement {
    sid    = "allow eks"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

resource "aws_ecr_repository_policy" "optar" {
  repository = aws_ecr_repository.optar.name
  policy     = data.aws_iam_policy_document.optar.json
}