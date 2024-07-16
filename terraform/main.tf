
module "optar" {
    source = "./modules/eks"
    
    stage        = "dev"
    project_name = "optar"
    account_id   = "705632797485"
    app_cache_arn = module.s3.app_cache_arn
    vpc_id = module.network.vpc_id
    subnet_ids = module.network.vpc_subnet_ids
}

module "network" {
    source = "./modules/network"
    
    stage        = "dev"
    project_name = "optar"
    account_id   = "705632797485"
}

module "s3" {
    source = "./modules/s3"
    
    stage        = "dev"
    project_name = "optar"
    account_id   = "705632797485"
}

module "ecr" {
    source = "./modules/ecr"
    
    stage        = "dev"
    project_name = "optar"
    account_id   = "705632797485"
}