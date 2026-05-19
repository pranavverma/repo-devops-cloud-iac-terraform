output "bucket_id"           { value = aws_s3_bucket.main.id }
output "bucket_arn"          { value = aws_s3_bucket.main.arn }
output "bucket_domain_name"  { value = aws_s3_bucket.main.bucket_regional_domain_name }
output "cloudfront_domain"   {
  value = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : null
}
