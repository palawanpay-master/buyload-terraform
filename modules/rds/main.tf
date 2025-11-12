
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.db_config.database_name}-${var.common.environment}-rds-subnets"
  subnet_ids = var.db_config.vpc_subnet_ids
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_security_group" "rds_proxy_security_group" {
  count       = var.db_config.publicly_accessible ? 0 : 1
  name        = "${var.common.project_name}-${var.common.environment}-rds-proxy-sg"
  description = "RDS Proxy Security Groups"
  vpc_id      = var.db_config.vpc_id

  ingress {
    from_port = 5432 # PostgreSQL default port
    to_port   = 5432 # PostgreSQL default port
    protocol  = "tcp"
    # Uncomment inbound rules if it is being utilized by the system
    security_groups = var.db_proxy_config.additional_ingress_security_groups
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-rds-sg"
  description = "RDS Security Groups"
  vpc_id      = var.db_config.vpc_id

  ingress {
    from_port = 5432 # PostgreSQL default port
    to_port   = 5432 # PostgreSQL default port
    protocol  = "tcp"
    security_groups = var.db_config.publicly_accessible ? var.db_config.additional_ingress_security_groups : concat(
      [element(aws_security_group.rds_proxy_security_group.*.id, 0)],
      var.db_config.additional_ingress_security_groups
    )
    cidr_blocks = var.db_config.additional_ingress_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_db_instance" "main_rds" {
  identifier                            = "${var.db_config.database_name}-${var.common.environment}-identifier"
  db_name                               = var.db_config.database_name
  username                              = var.db_config.username
  manage_master_user_password           = var.db_config.manage_master_user_password
  engine                                = var.db_config.engine
  engine_version                        = var.db_config.engine_version
  instance_class                        = var.db_config.instance_class
  port                                  = var.db_config.port
  storage_type                          = var.db_config.storage_type
  allocated_storage                     = var.db_config.allocated_storage
  max_allocated_storage                 = var.db_config.max_allocated_storage
  iops                                  = var.db_config.iops
  publicly_accessible                   = var.db_config.publicly_accessible
  multi_az                              = var.db_config.multi_az
  db_subnet_group_name                  = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids                = [aws_security_group.rds_security_group.id]
  availability_zone                     = var.db_config.availability_zone
  ca_cert_identifier                    = var.db_config.ca_cert_identifier
  performance_insights_enabled          = var.db_config.performance_insights_enabled
  performance_insights_retention_period = var.db_config.performance_insights_retention_period
  backup_retention_period               = var.db_config.backup_retention_period
  backup_window                         = var.db_config.backup_window
  maintenance_window                    = var.db_config.maintenance_window
  copy_tags_to_snapshot                 = var.db_config.copy_tags_to_snapshot
  monitoring_interval                   = var.db_config.monitoring_interval
  deletion_protection                   = var.db_config.deletion_protection
  skip_final_snapshot                   = var.db_config.skip_final_snapshot
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_secretsmanager_secret" "rds_proxy_strapi_secret" {
  count       = var.db_config.publicly_accessible ? 0 : 1
  name        = "${var.common.project_name}-${var.common.environment}-rds-proxy-secret"
  description = "RDS Proxy Secret"

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}


resource "aws_iam_role" "rds_proxy_role" {
  count = var.db_config.publicly_accessible ? 0 : 1
  name  = "${var.common.project_name}-${var.common.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com",
        },
      },

    ],
  })

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }

}

resource "aws_iam_role_policy" "rds_proxy_role_policy" {
  count = var.db_config.publicly_accessible ? 0 : 1
  name  = "${var.common.project_name}-${var.common.environment}-rds-proxy-role-policy"
  role  = element(aws_iam_role.rds_proxy_role.*.name, 0)

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GetSecretValue",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_db_instance.main_rds.master_user_secret[0].secret_arn}",
          "${aws_secretsmanager_secret.rds_proxy_strapi_secret[0].arn}"
        ]
      },
      {
        "Sid" : "DecryptSecretValue",
        "Action" : [
          "kms:Decrypt"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_db_instance.main_rds.master_user_secret[0].kms_key_id}"
        ],
        "Condition" : {
          "StringEquals" : {
            "kms:ViaService" : "secretsmanager.${var.common.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_db_proxy" "rds_proxy" {
  count                  = var.db_config.publicly_accessible ? 0 : 1
  name                   = "${var.common.project_name}-${var.common.environment}-db-proxy"
  engine_family          = var.db_proxy_config.engine_family
  role_arn               = element(aws_iam_role.rds_proxy_role.*.arn, 0)
  vpc_subnet_ids         = var.db_config.vpc_subnet_ids
  vpc_security_group_ids = [element(aws_security_group.rds_proxy_security_group.*.id, 0)]
  debug_logging          = var.db_proxy_config.debug_logging
  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = var.db_proxy_config.client_password_auth_type
    description               = "DB Proxy Authentication"
    iam_auth                  = var.db_proxy_config.iam_auth
    # secret_arn                = aws_db_instance.main_rds.master_user_secret[0].secret_arn
    secret_arn = aws_secretsmanager_secret.rds_proxy_strapi_secret[0].arn
  }

  require_tls         = true
  idle_client_timeout = var.db_proxy_config.idle_client_timeout

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_db_proxy_default_target_group" "rds_proxy_default_target_group" {
  count         = var.db_config.publicly_accessible ? 0 : 1
  db_proxy_name = element(aws_db_proxy.rds_proxy.*.name, 0)

  connection_pool_config {
    connection_borrow_timeout = var.db_proxy_config.connection_borrow_timeout
    max_connections_percent   = var.db_proxy_config.max_connections_percent
  }
}

resource "aws_db_proxy_target" "rds_proxy_target" {
  count                  = var.db_config.publicly_accessible ? 0 : 1
  db_instance_identifier = aws_db_instance.main_rds.identifier
  db_proxy_name          = element(aws_db_proxy.rds_proxy.*.name, 0)
  target_group_name      = element(aws_db_proxy_default_target_group.rds_proxy_default_target_group.*.name, 0)
}
