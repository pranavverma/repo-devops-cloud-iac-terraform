###############################################################################
# Database module
# Provisions an RDS PostgreSQL instance in a private subnet group with
# automated backups, encryption at rest, and a dedicated security group.
###############################################################################

terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "Allow PostgreSQL inbound from the ECS security group only."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-db" })
}

resource "aws_db_instance" "main" {
  identifier             = "${var.name_prefix}-postgres"
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage_gb
  max_allocated_storage  = var.max_allocated_storage_gb
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = var.multi_az
  backup_retention_period = var.backup_retention_days
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  publicly_accessible    = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-postgres" })
}
