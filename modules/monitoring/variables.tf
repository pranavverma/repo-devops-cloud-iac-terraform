variable "name_prefix"            { type = string }
variable "ecs_cluster_name"        { type = string }
variable "ecs_service_name"        { type = string }
variable "db_instance_id"          { type = string; default = "" }
variable "alb_arn_suffix"          { type = string; default = "" }
variable "alert_email"             { type = string; default = "" }
variable "ecs_cpu_threshold_pct"   { type = number; default = 80 }
variable "rds_cpu_threshold_pct"   { type = number; default = 80 }
variable "alb_5xx_threshold"       { type = number; default = 10 }
variable "tags"                    { type = map(string); default = {} }
