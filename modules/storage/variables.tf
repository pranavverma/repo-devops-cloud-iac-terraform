variable "bucket_name"        { type = string }
variable "enable_versioning"  { type = bool; default = true }
variable "enable_cloudfront"  { type = bool; default = false }
variable "force_destroy"      { type = bool; default = false }
variable "tags"               { type = map(string); default = {} }
