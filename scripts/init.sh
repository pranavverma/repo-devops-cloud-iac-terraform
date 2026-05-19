#!/usr/bin/env bash
# Bootstrap Terraform state storage (run once per AWS account).
# Creates the S3 bucket and DynamoDB table used by the S3 backend.
#
# Usage: ./scripts/init.sh <bucket-name> <region>

set -euo pipefail

BUCKET="${1:?Usage: $0 <state-bucket-name> <region>}"
REGION="${2:-us-east-1}"
TABLE="terraform-state-lock"

echo "Creating S3 state bucket: $BUCKET in $REGION"
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  $( [[ "$REGION" != "us-east-1" ]] && echo "--create-bucket-configuration LocationConstraint=$REGION" )

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

echo "Creating DynamoDB lock table: $TABLE"
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" || echo "Table may already exist — skipping."

echo "Bootstrap complete."
echo "Update the backend {} blocks in environments/*/main.tf with:"
echo "  bucket = \"$BUCKET\""
echo "  region = \"$REGION\""
