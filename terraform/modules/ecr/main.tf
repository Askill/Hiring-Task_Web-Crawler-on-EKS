
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

data "aws_iam_policy_document" "eks" {
  statement {
    sid    = "allow eks"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.account_id]
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

resource "aws_ecr_repository_policy" "eks" {
  repository = aws_ecr_repository.eks.name
  policy     = data.aws_iam_policy_document.eks.json
}