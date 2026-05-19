###############################################################################
# Dev environment — lightweight, single-AZ, no HA database
###############################################################################

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }

  # Uncomment to enable remote state in S3
  # backend "s3" {
  #   bucket         = "my-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "networking" {
  source             = "../../modules/networking"
  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = false # dev: save cost, use public subnets for tasks
  tags               = local.common_tags
}

module "compute" {
  source             = "../../modules/compute"
  name_prefix        = local.name_prefix
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.public_subnet_ids # reuse public in dev
  aws_region         = var.aws_region
  container_image    = var.container_image
  container_port     = var.container_port
  task_cpu           = 256
  task_memory        = 512
  desired_count      = 1
  env_vars           = var.env_vars
  tags               = local.common_tags
}

module "database" {
  source                     = "../../modules/database"
  name_prefix                = local.name_prefix
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.public_subnet_ids
  allowed_security_group_ids = [module.compute.ecs_sg_id]
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  instance_class             = "db.t3.micro"
  multi_az                   = false
  skip_final_snapshot        = true
  deletion_protection        = false
  tags                       = local.common_tags
}

module "storage" {
  source          = "../../modules/storage"
  bucket_name     = "${local.name_prefix}-assets"
  enable_cloudfront = false
  tags            = local.common_tags
}

module "monitoring" {
  source           = "../../modules/monitoring"
  name_prefix      = local.name_prefix
  ecs_cluster_name = module.compute.ecs_cluster_id
  ecs_service_name = module.compute.ecs_service_name
  db_instance_id   = module.database.db_instance_id
  alert_email      = var.alert_email
  tags             = local.common_tags
}
