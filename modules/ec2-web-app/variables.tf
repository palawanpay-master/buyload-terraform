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
variable "web_app_config" {
  type = object({
    ami             = string # "ami-0440d3b780d96b29d" Amazon Linux 2 AMI
    instance_type   = string
    vpc_id          = string
    private_subnets = list(string)
    public_subnets  = list(string)
    user_data       = string
    # #!/bin/bash
    # echo "Starting user_data script" >> /tmp/user_data.log
    # sudo yum update -y >> /tmp/user_data.log 2>&1
    # sudo yum install -y httpd >> /tmp/user_data.log 2>&1
    # sudo systemctl enable httpd >> /tmp/user_data.log 2>&1
    # sudo systemctl start httpd >> /tmp/user_data.log 2>&1
    # echo "<html><h1>Welcome to your Apache server on Amazon Linux 2!</h1></html>" | sudo tee /var/www/html/index.html
    # EOF
    acm_certificate_arn = string
  })
}
