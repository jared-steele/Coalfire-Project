terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 1) Network (VPC, subnets, IGW, NAT, routes)
module "network" {
  source        = "./modules/network"
  vpc_cidr      = var.vpc_cidr
  mgmt_cidr     = var.mgmt_cidr
  app_cidr      = var.app_cidr
  backend_cidr  = var.backend_cidr
  tags          = var.tags
}

# 2) Security (security groups live in the VPC)
module "security" {
  source     = "./modules/security"
  vpc_id     = module.network.vpc_id
  admin_cidr = var.admin_cidr
  tags       = var.tags
}

# 3) Compute (mgmt EC2, LT/ASG, internal ALB)
module "compute" {
  source         = "./modules/compute"
  # nets
  vpc_id         = module.network.vpc_id
  subnet_mgmt_id = module.network.subnet_ids.mgmt
  subnet_app_id  = module.network.subnet_ids.app
  subnet_be_id   = module.network.subnet_ids.backend
  # sgs
  sg_mgmt_id     = module.security.sg_mgmt_id
  sg_app_id      = module.security.sg_app_id
  sg_alb_id      = module.security.sg_alb_id
  # sizing
  instance_type  = var.instance_type
  key_name       = var.key_name
  asg_min        = var.asg_min
  asg_max        = var.asg_max
  tags           = var.tags
}

