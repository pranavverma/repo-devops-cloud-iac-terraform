variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. 'myapp-prod')."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. '10.0.0.0/16')."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to spread subnets across. Must contain at least 2."
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Provide at least 2 availability zones for high availability."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway in each AZ so private subnets can reach the internet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}
