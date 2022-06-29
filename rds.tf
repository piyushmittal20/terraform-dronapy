module "db" {
  source            = "terraform-aws-modules/rds/aws"
  version           = "~> 3.0"
  count             = 1
  identifier        = "${var.name}-${count.index}"
  instance_class    = var.database_instance_class
  engine            = var.database_engine
  engine_version    = var.database_engine_version
  family            = "postgres13"
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.database_storage_encrypted
  #kms_key_id        = aws_kms_key.rds.id
  name     = var.db_name
  username = var.master_username
  # password               = aws_secretsmanager_secret_version.db-pass-drona-service-val.secret_string
  password               = var.master_password
  port                   = "5432"
  vpc_security_group_ids = [aws_security_group.vpc_postgres.id]
  backup_window          = var.preferred_backup_window
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = var.database_apply_immediately
  subnet_ids             = module.vpc.database_subnets

  tags = {
    Environment = var.env
    Terraform   = "true"
  }

}


# resource "aws_rds_cluster_parameter_group" "postgresql_cpg" {
#   name        = "${var.cluster_identifier}-postgres14-cluster-parameter-group"
#   family      = "postgres14"
#   description = "${var.cluster_identifier}-postgres14-cluster-parameter-group"
# }

resource "aws_db_parameter_group" "postgresql_dpg" {
  name        = "${var.cluster_identifier}-postgres14-parameter-group"
  family      = "postgres14"
  description = "${var.cluster_identifier}-postgres14-parameter-group"
}


resource "aws_security_group" "vpc_postgres" {
  name        = "VPC_POSTGRES_ALLOW"
  description = "Allow POSTGRES inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "POSTGRES from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}

resource "aws_kms_key" "rds" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
