output "app_cache_arn" {
  description = "ARN of the bucket used as a cache"
  value       = aws_s3_bucket.app_cache.arn
}