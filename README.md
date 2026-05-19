# Cloud Infrastructure as Code — Terraform / AWS

A modular, production-grade Terraform codebase for provisioning a complete
AWS application stack: VPC, ECS Fargate, RDS PostgreSQL, S3 with optional
CloudFront CDN, and CloudWatch monitoring — across dev, staging, and production
environments with one command.

---

## Architecture

```
                          ┌─────────────────────────────────────┐
                          │              AWS VPC                 │
                          │                                      │
  Internet  ──────────► IGW                                      │
                          │                                      │
                  ┌───────▼────────┐                             │
                  │   Public AZs   │  ALB + NAT Gateways         │
                  └───────┬────────┘                             │
                          │ (private traffic)                    │
                  ┌───────▼────────┐                             │
                  │  Private AZs   │  ECS Fargate tasks          │
                  │                │  RDS PostgreSQL (multi-AZ)  │
                  └────────────────┘                             │
                          │                                      │
             S3 Assets ◄──┘         CloudFront CDN               │
             (+ CloudFront)         CloudWatch + SNS Alerts      │
                          └─────────────────────────────────────┘
```

### Modules

| Module | Provisions |
|--------|-----------|
| `networking` | VPC, public + private subnets, IGW, NAT Gateways, route tables |
| `compute` | ECS Cluster, Fargate task definition + service, ALB, security groups |
| `database` | RDS PostgreSQL, subnet group, encrypted storage, automated backups |
| `storage` | S3 bucket with versioning, encryption, lifecycle rules, optional CloudFront |
| `monitoring` | SNS alerts topic, CloudWatch alarms (CPU, memory, 5xx), dashboard |

---

## Technical stack

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.7 |
| AWS Provider | ~> 5.0 |
| Remote state | S3 + DynamoDB lock |
| CI/CD | GitHub Actions |

---

## Prerequisites

- **Terraform 1.7+** — `terraform version`
- **AWS CLI** configured (`aws configure`) or IAM role attached to CI runner
- **AWS credentials** with permission to create VPC, ECS, RDS, S3, CloudWatch, IAM

---

## Quick start

### 1. Bootstrap remote state (once per account)

```bash
chmod +x scripts/init.sh
./scripts/init.sh my-terraform-state-bucket us-east-1
```

Then update the `backend "s3" {}` block in `environments/prod/main.tf` with the bucket name.

### 2. Deploy the dev environment

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your container image and DB password

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Or use the Makefile

```bash
# Init dev environment
make init ENV=dev

# Plan changes
make plan ENV=dev

# Apply
make apply ENV=dev
```

---

## Environment comparison

| Feature | dev | staging | prod |
|---------|-----|---------|------|
| NAT Gateway | ✗ | ✓ | ✓ |
| Task CPU | 256 | 512 | 1024 |
| Task memory | 512 MB | 1 GB | 2 GB |
| Desired count | 1 | 2 | 3 |
| RDS instance | t3.micro | t3.micro | t3.small |
| Multi-AZ RDS | ✗ | ✗ | ✓ |
| CloudFront | ✗ | ✗ | ✓ |
| Deletion protection | ✗ | ✗ | ✓ |
| Remote state | optional | optional | ✓ |

---

## Module reference

### networking

| Variable | Default | Description |
|----------|---------|-------------|
| `name_prefix` | — | Prefix for all resource names |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `availability_zones` | — | List of AZs (min 2) |
| `enable_nat_gateway` | `true` | Create NAT Gateways for private subnets |

### compute

| Variable | Default | Description |
|----------|---------|-------------|
| `container_image` | — | Docker image URI |
| `container_port` | `8080` | Port exposed by the container |
| `task_cpu` | `512` | Fargate CPU units |
| `task_memory` | `1024` | Fargate memory (MiB) |
| `desired_count` | `2` | Running task instances |
| `health_check_path` | `/health` | ALB health check endpoint |

### database

| Variable | Default | Description |
|----------|---------|-------------|
| `instance_class` | `db.t3.micro` | RDS instance type |
| `multi_az` | `false` | Enable Multi-AZ standby |
| `backup_retention_days` | `7` | Automated backup window |
| `deletion_protection` | `false` | Prevent accidental deletion |

### monitoring

| Variable | Default | Description |
|----------|---------|-------------|
| `alert_email` | `""` | Email address for SNS alerts |
| `ecs_cpu_threshold_pct` | `80` | Alarm above this ECS CPU % |
| `alb_5xx_threshold` | `10` | Alarm above this 5xx count/min |

---

## CI/CD — GitHub Actions

The workflow at `.github/workflows/terraform.yml` runs on every PR and push to main:

| Trigger | Job | Action |
|---------|-----|--------|
| Pull Request | `validate` | `fmt -check` + `validate` all modules |
| Pull Request | `plan-dev` | `terraform plan` for the dev environment |
| Push to main | `apply-prod` | `terraform apply` for production |

**Required GitHub Secrets:**

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key |
| `CONTAINER_IMAGE` | Docker image URI to deploy |
| `DB_PASSWORD` | RDS master password |

---

## Project layout

```
├── .github/
│   └── workflows/
│       └── terraform.yml     CI/CD pipeline
├── environments/
│   ├── dev/                  Lightweight, cost-optimised, no HA
│   │   ├── main.tf           Module composition + provider config
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── staging/              Mirrors prod topology at reduced size
│   └── prod/                 Full HA, multi-AZ, deletion protection
├── modules/
│   ├── networking/           VPC, subnets, IGW, NAT, route tables
│   ├── compute/              ECS Fargate, ALB, security groups, IAM
│   ├── database/             RDS PostgreSQL, subnet group, encryption
│   ├── storage/              S3, versioning, encryption, CloudFront
│   └── monitoring/           CloudWatch alarms, SNS, dashboard
├── scripts/
│   └── init.sh               Bootstrap S3 state bucket + DynamoDB lock table
└── Makefile                  Convenience wrapper around terraform CLI
```

---

## Extending this

- **Auto-scaling** — add `aws_appautoscaling_target` + `aws_appautoscaling_policy`
  to the compute module to scale ECS tasks based on CPU or ALB request count.
- **Secrets Manager** — replace plaintext `db_password` variable with an
  `aws_secretsmanager_secret` resource and inject the ARN into the task definition.
- **HTTPS** — add `aws_acm_certificate` + an HTTPS listener to the ALB module
  and attach your domain via Route 53.
- **Additional regions** — create `environments/prod-eu/` with a different
  provider `region` and separate state key for a multi-region deployment.
