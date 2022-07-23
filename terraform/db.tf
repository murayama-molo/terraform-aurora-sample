module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform-aurora-sample-db-security-group-${terraform.workspace}"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/24"]
  ingress_rules       = ["postgresql-tcp"]
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.3"
}

module "aurora_postgresql_serverlessv2" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = "terraform-aurora-sample-postgresqlv2-${terraform.workspace}"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example_postgresql14.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example_postgresql14.id

  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}

resource "aws_db_parameter_group" "example_postgresql14" {
  name        = "terraform-aurora-sample-aurora-db-postgres14-parameter-group-${terraform.workspace}"
  family      = "aurora-postgresql14"
  description = "terraform-aurora-sample-aurora-db-postgres14-parameter-group-${terraform.workspace}"
  tags = {
    Name = "example"
  }
}

resource "aws_rds_cluster_parameter_group" "example_postgresql14" {
  name        = "terraform-aurora-sample-aurora-postgres14-cluster-parameter-group-${terraform.workspace}"
  family      = "aurora-postgresql14"
  description = "terraform-aurora-sample-aurora-postgres14-cluster-parameter-group-${terraform.workspace}"
  tags = {
    Name = "example"
  }
}

# resource "aws_rds_cluster" "example" {
#   cluster_identifier                  = "terraform-aurora-sample-cluster-identifier-${terraform.workspace}"
#   engine                              = "aurora-postgresql"
#   engine_version                      = "14.3"
#   engine_mode                         = "provisioned"
#   master_username                     = "postgres"
#   master_password                     = "postgres"
#   port                                = 5432
#   database_name                       = "TerraformAuroraSample"
#   vpc_security_group_ids              = [module.vote_service_sg.security_group_id]
#   db_subnet_group_name                = aws_db_subnet_group.example.name
#   db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.example.name
#   iam_database_authentication_enabled = true

#   serverlessv2_scaling_configuration {
#     min_capacity = 0.5
#     max_capacity = 1.0
#   }

#   skip_final_snapshot = true
#   apply_immediately   = true

#   tags = {
#     Name = "example"
#   }
# }

# resource "aws_rds_cluster_instance" "example" {
#   cluster_identifier = aws_rds_cluster.example.id
#   identifier         = "${aws_rds_cluster.example.cluster_identifier}-serverless-instance-${terraform.workspace}"

#   engine                  = aws_rds_cluster.example.engine
#   engine_version          = aws_rds_cluster.example.engine_version
#   instance_class          = "db.serverless"
#   db_subnet_group_name    = aws_db_subnet_group.example.name
#   db_parameter_group_name = aws_db_parameter_group.example.name

#   monitoring_role_arn = aws_iam_role.aurora_monitoring.arn
#   monitoring_interval = 60

#   publicly_accessible = true
# }

# resource "aws_db_subnet_group" "example" {
#   name       = "terraform-aurora-sample-db-subnet-group-${terraform.workspace}"
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Name = "example"
#   }
# }

# resource "aws_rds_cluster_parameter_group" "example" {
#   name   = "terraform-aurora-sample-db-cluster-parameter-group-${terraform.workspace}"
#   family = "aurora-postgresql14"

#   tags = {
#     Name = "example"
#   }
# }

# resource "aws_db_parameter_group" "example" {
#   name   = "terraform-aurora-sample-db-parameter-group-${terraform.workspace}"
#   family = "aurora-postgresql14"

#   parameter {
#     apply_method = "pending-reboot"
#     name         = "shared_preload_libraries"
#     value        = "pg_stat_statements,pg_hint_plan"
#   }
# }
