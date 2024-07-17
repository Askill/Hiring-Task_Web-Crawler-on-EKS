
module "optar" {
  source = "./modules/eks"

  stage        = var.stage
  project_name = var.project_name
  account_id   = var.account_id

  app_cache_arn = module.s3.app_cache_arn
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.vpc_subnet_ids
}

module "network" {
  source = "./modules/network"

  stage        = var.stage
  project_name = var.project_name
  account_id   = var.account_id
}

module "s3" {
  source       = "./modules/s3"
  stage        = var.stage
  project_name = var.project_name
  account_id   = var.account_id
}

module "ecr" {
  source = "./modules/ecr"

  stage        = var.stage
  project_name = var.project_name
  account_id   = var.account_id
}