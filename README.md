# Requirements

1. awscli2

- Follow this url for installation (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Setup awscli2 profile defined in the project

2. Terraform Cli

- Follow this url (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

# Directory Definition

1. backend-s3

   **This must always be the first directory to be deployed**

   Terraform uses a file called `terraform.tfstate` this file is very important because terraform uses this as a
   means to check if the version and changes within the services we wish to provision. Think of it like a `package.lock.json` where its always necessary to have the correct version of the dependencies we use across all developers who will use this repository.

   By default Terraform stores the `terraform.tfstate` file locally. If there are multiple developers using terraform it will be mandatory to add this file within the repository

   There are two major problems:

   1. `terraform.tfstate` file contains **SENSITIVE** information. Let's say we provision an RDS instance we normally define a password for it, Terraform stores these kinds of information within the file.
   2. Since it is mandatory that terraform has this file for tracking what has it provisioned, it will be mandatory to push this file in the repository. Developers must constantly align with one another before applying changes.

   Now the main purpose of `backend-s3` is to resolve these problems, where this will now upload the `terraform.tfstate` file in s3 and check the state from there. This also prevents accidental updates by utilizing dynamodb as a tool for **state-locking** which process each deployments one a time.

2. Environment Directories (development, staging, beta, prod)

   **This is where we deploy services per environment**

   In Terraform in order to support multi environment deployment we create sub-directories for them because
   Each services per environment are configured differently, and we cannot have them all in one state file.

3. modules

   **We do not deploy in this direcotry we just import them in the environment directories, where deployment will happen from there**

   This part is very straight forward this is where we define what AWS services we want deploy that are **reusable** for the project, and example for this would be a VPC normally all environments must have their own VPC so we create a VPC module where all environments can reuse, but we configure the variables on the environment level.

# Deployment Commands

1. terraform init / terraform init --var-file=../env.tfvars
2. terraform plan (MANDATORY)
3. terraform apply
4. terraform destroy (CONSULT WITH THE TEAM BEFORE RUNNING THIS COMMAND AS THIS WILL DELETE EVERYTHING)

# Format all the terraform scripts

 terraform fmt -check -recursive