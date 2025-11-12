terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Note variables cannot be used here, as an alternative we hard code the values
    # Initially we deploy backend-s3 first, then deploy an environment we just need
    # To keep in mind of the following:
    # - bucket and dynamodb_table prefix = the name of the project
    # - region = region of the s3 and dynamodb
    # - key = prefix of the environment e.g. (sandbox, dev, staging, uat, beta, prod)
    bucket = "ppay-buyload-dev-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
    # Uncomment this if you are running this locally
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "ppay-buyload-dev"
  }
}

locals {
  common = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.region
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  # Uncomment this if you are running this locally
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
}


module "lambda-config" {
  source = "../modules/lambda-config"
  common = local.common
  lambda_config = {
    vpc_id = var.vpc_id
  }
}


module "execute_api_vpc_endpoint" {
  source = "../modules/api-gateway-vpc-endpoint"
  common = local.common
  params = {
    service_name_suffix = "execute-api"
    vpc_id              = var.vpc_id
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = var.security_group_ids
  }
}

module "logs_vpc_endpoint" {
  source = "../modules/api-gateway-vpc-endpoint"
  common = local.common
  params = {
    service_name_suffix = "logs"
    vpc_id              = var.vpc_id
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = var.security_group_ids
  }
}
module "monitoring_vpc_endpoint" {
  source = "../modules/api-gateway-vpc-endpoint"
  common = local.common
  params = {
    service_name_suffix = "monitoring"
    vpc_id              = var.vpc_id
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = var.security_group_ids
  }
}



# Centralized bucket for storing all necesarry objects
module "s3-private-storage" {
  source               = "../modules/s3-private-storage"
  create_ssm_parameter = true
  bucket_name          = "storage"
  common               = local.common
}

module "s3-serverless-artifacts" {
  source               = "../modules/s3-private-storage"
  create_ssm_parameter = false
  needs_versioning     = true
  bucket_name          = "serverless-artifacts"
  common               = local.common
}
module "s3-assets-storage" {
  source = "../modules/s3-public-storage"
  common = local.common
}

# Cognito for authentication
module "cognito-user-pool" {
  source = "../modules/cognito-admin"
  common = local.common
}

module "external-ssm-parameters" {
  source = "../modules/external-ssm-parameters"
  common = local.common
  params = {
    mongodb_uri        = var.mongodb_uri
    security_group_ids = var.security_group_ids
    subnet_ids         = var.private_subnet_ids
  }
}


