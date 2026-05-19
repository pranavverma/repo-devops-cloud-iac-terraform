variable "name_prefix"               { type = string }
variable "vpc_id"                    { type = string }
variable "private_subnet_ids"        { type = list(string) }
variable "allowed_security_group_ids"{ type = list(string); default = [] }
variable "db_name"                   { type = string }
variable "db_username"               { type = string }
variable "db_password"               { type = string; sensitive = true }
variable "postgres_version"          { type = string; default = "16.2" }
variable "instance_class"            { type = string; default = "db.t3.micro" }
variable "allocated_storage_gb"      { type = number; default = 20 }
variable "max_allocated_storage_gb"  { type = number; default = 100 }
variable "multi_az"                  { type = bool; default = false }
variable "backup_retention_days"     { type = number; default = 7 }
variable "skip_final_snapshot"       { type = bool; default = true }
variable "deletion_protection"       { type = bool; default = false }
variable "tags"                      { type = map(string); default = {} }
