variable "name_prefix"       { type = string }
variable "vpc_id"            { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids"{ type = list(string) }
variable "aws_region"        { type = string; default = "us-east-1" }

variable "container_image" {
  description = "Docker image URI (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:latest)."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of ECS task instances to run."
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "ALB target group health check endpoint."
  type        = string
  default     = "/health"
}

variable "env_vars" {
  description = "Environment variables injected into the container."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
