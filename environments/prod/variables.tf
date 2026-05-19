variable "project_name"       { type = string }
variable "environment"        { type = string; default = "prod" }
variable "aws_region"         { type = string; default = "us-east-1" }
variable "vpc_cidr"           { type = string; default = "10.1.0.0/16" }
variable "availability_zones" { type = list(string); default = ["us-east-1a", "us-east-1b", "us-east-1c"] }
variable "container_image"    { type = string }
variable "container_port"     { type = number; default = 8080 }
variable "desired_count"      { type = number; default = 3 }
variable "env_vars"           { type = map(string); default = {} }
variable "db_name"            { type = string }
variable "db_username"        { type = string }
variable "db_password"        { type = string; sensitive = true }
variable "alert_email"        { type = string }
