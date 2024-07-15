terraform {
  backend "s3" {
    bucket               = "web-crawler-on-eks-tf-state"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "template"
    region               = "eu-central-1"
  }
}