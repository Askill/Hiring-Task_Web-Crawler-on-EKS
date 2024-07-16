

output "vpc_id" {
  description = "ID of the created vpcto be used in eks module"
  value       = module.vpc.vpc_id
}

output "vpc_subnet_ids" {
  description = "IDs of the subnets to be used by kuernetes"
  value       = module.vpc.private_subnets
}