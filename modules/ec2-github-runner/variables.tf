# [MANDATORY] 
#  - Define common for consuming shared parameters
#  - Omit any parameters that are not needed
variable "common" {
  type = object({
    project_name = string
    environment  = string
    region       = string
  })

}

# This bastion is accessed via SSM 
variable "github_runner_config" {
  type = object({
    ami           = string # "ami-0440d3b780d96b29d" Amazon Linux 2 AMI
    instance_type = string
    vpc_id        = string
    subnet_id     = string
    user_data     = string # <<-EOF
    # #!/bin/bash
    # echo "Starting user_data script" >> /tmp/user_data.log
    # sudo yum update -y >> /tmp/user_data.log 2>&1
    # sudo amazon-linux-extras enable postgresql15 >> /tmp/user_data.log 2>&1
    # sudo yum install -y postgresql15 >> /tmp/user_data.log 2>&1
    # EOF
  })
}
