output "ecr" {
  description = "ARN of the bucket used as a cache"
  value       = aws_ecr_repository.optar.arn
}