# Module Use Case

- Modules are the reusable code we define so that deployment to stages in our development cycle would be much easier.

- Modules are defined by a directory name e.g. **/modules/vpc** and it consists its own **main.tf**, **output.tf**
  and **variables.tf**

- We do not deploy modules individually, but we define modules under the environment directory e.g.

  under our **/development** directory we have defined a file called **main.tf**

  ```
    module "vpc" {
        source = "../modules/vpc"
        common = local.common
        vpc_config = {
            vpc_cidr                       = "10.36.0.0/16"
            public_subnet_cidrs            = ["10.36.0.0/20", "10.36.16.0/20"]
            private_subnet_cidrs           = ["10.36.128.0/20", "10.36.144.0/20"]
            availability_zones             = ["${var.region}a", "${var.region}b"]
            nat_gateway_availability_zones = "single"
        }
    }
  ```

  In this example we are instantiating the vpc module and pass our desired variables so that we can define
  the proper configuration for each environment.

# Modules directory structure

- As mentioned each module consists its own **main.tf**, **output.tf** and **variables.tf** but what is actually
  Their use-cases

  **main.tf** - This is where we define our module resources on the example shown below, we are using the resource tag to define the resource we want to provision

  ```
    resource "aws_s3_bucket" "backend" {
        bucket = "${var.common.project_name}-${var.common.environment}-${var.common.region}-backend"

        tags = {
            Environment      = var.common.environment
            Project          = var.common.project_name
            TerraformManaged = true
        }
    }

    resource "aws_s3_bucket" "admin_frontend" {
        bucket = "${var.common.project_name}-${var.common.environment}-admin-frontend"
        tags = {
            Environment      = var.common.environment
            Project          = var.common.project_name
            TerraformManaged = true
        }
    }
  ```

  **variables.tf** - This is responsible for creating a structured variable for our resources, as shown above
  we normally want to name our vpc based on the project and environment. To create a variable we simply use the
  variable tag.

  ```
    variable "common" {
        type = object({
            project_name = string
            environment  = string
            region       = string
        })
    }

  ```

  **outputs.tf** - We use the outputs.tf it to make module variable accessible.

  In this case the s3 bucket name, we use the output tag and define its value
  To use it we simply call the module and the defined output variable.

  ```
    ** /modules/vpc/output.tf **

    output "s3_output_admin_frontend_bucket" {
        value = aws_s3_bucket.admin_frontend
    }


    ** /development/main.tf

    module "cloudfront" {
        source = "../modules/cloudfront"
        common = local.common
        s3_config = {
            aws_acm_arm           = var.aws_acm_arn
            admin_frontend_bucket = module.s3.s3_output_admin_frontend_bucket
            admin_portal_alias    = "${var.environment}.{define-your-domain-name}"
        }
    }

  ```

**ssm.tf** - We use the ssm.tf it to make SSM parameter variables that can be utilized by our application

For SSM we again use the resource tag, we define it in this directory for easy checking what parameters have we
provisioned

```
  resource "aws_ssm_parameter" "ssm_s3_backend_bucket" {
      name        = "/${var.common.project_name}/${var.common.environment}/s3/backend/bucket"
      description = "Backend S3 Bucket"
      type        = "String"
      value       = aws_s3_bucket.backend.bucket
      tags = {
          Environment      = var.common.environment
          Project          = var.common.project_name
          TerraformManaged = true
      }
  }
```
