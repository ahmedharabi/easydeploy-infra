# EasyDeploy Infra

Terraform infrastructure for EasyDeploy on AWS.

## Layout

- `environments/prod`: root module for the production environment
- `modules/vpc`: reusable VPC module wrapper
- `modules/eks`: reusable EKS module wrapper
- `modules/ecr`: reusable ECR repository module

## What This Provisions

- VPC with public/private subnets
- EKS cluster with managed node group
- ECR repository for application images
- IAM access entries for EKS admin access (cluster scope)

## Prerequisites

- Terraform `>= 1.6.0`
- AWS credentials configured in your shell (`aws configure` or env vars)
- Permissions to create VPC, EKS, IAM, and ECR resources

## Usage

From this directory:

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

Or without changing directory:

```bash
terraform -chdir=environments/prod init
terraform -chdir=environments/prod plan
terraform -chdir=environments/prod apply
```

## Key Variables (`environments/prod/terraform.tfvars`)

- `aws_region`, `project`, `environment`
- VPC settings: `vpc_cidr`, `azs`, `private_subnets`, `public_subnets`
- EKS settings: `cluster_version`, node group sizing and instance type
- EKS admin access: `admin_principal_arns`
- ECR settings: `ecr_image_tag_mutability`, `ecr_scan_on_push`, `ecr_force_delete`

Example for EKS admin access:

```hcl
admin_principal_arns = [
  "arn:aws:iam::<account-id>:user/<username>",
  # "arn:aws:iam::<account-id>:role/<role-name>",
]
```

## Useful Outputs

After apply, Terraform outputs include:

- `cluster_name`
- `cluster_endpoint`
- `kubeconfig_command`
- `vpc_id`
- `oidc_provider_arn`
- `ecr_repository_name`
- `ecr_repository_arn`
- `ecr_repository_url`

## Notes

- State is currently local in `environments/prod`. Consider adding a remote backend (S3 + DynamoDB lock) before team usage.
- IAM access to EKS is managed through EKS access entries in Terraform.
