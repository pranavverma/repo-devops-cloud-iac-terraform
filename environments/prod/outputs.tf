output "alb_dns_name"        { value = module.compute.alb_dns_name }
output "cloudfront_domain"  { value = module.storage.cloudfront_domain }
output "db_endpoint"         { value = module.database.db_endpoint }
output "assets_bucket"       { value = module.storage.bucket_id }
output "sns_alert_topic"     { value = module.monitoring.sns_topic_arn }
