terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State is stored locally. Add a backend "s3" {} block here for remote state.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "easydeploy"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  cluster_name        = "${var.project}-${var.environment}"
  ecr_repository_name = "${var.project}-${var.environment}-app"
}

# ── VPC ──────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/vpc"

  vpc_name        = "${var.project}-${var.environment}"
  cidr            = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  cluster_name    = local.cluster_name
}

# ── EKS ──────────────────────────────────────────────────────────────────────

module "eks" {
  source = "../../modules/eks"

  cluster_name         = local.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  node_instance_types  = var.node_instance_types
  node_capacity_type   = var.node_capacity_type
  node_min_size        = var.node_min_size
  node_desired_size    = var.node_desired_size
  node_max_size        = var.node_max_size
  environment          = var.environment
  admin_principal_arns = var.admin_principal_arns
}

# ── ECR ──────────────────────────────────────────────────────────────────────

module "ecr" {
  source = "../../modules/ecr"

  repository_name      = local.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  force_delete         = var.ecr_force_delete
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
