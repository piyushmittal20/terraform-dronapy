# stage ENV
variable "env" {
  default = "test"
}

# variable "tfstate" {
#   default = "drona-test2-terraform"
# }

variable "name" {
  default = "drona-test"
}

variable "eks" {
  default = "eks-test-template"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}


variable "git_repo" {
  default = "drona-ioc"
}

variable "flow_log" {
  default = "drona-test-vpc-flow-log"
}
# stage's cidr block
variable "env-cidr" {
  default = "10.1.0.0/16"
}
# The default region
variable "region" {
  default = "ap-south-1"
}
# test's Project name
variable "project" {
  default = "drona"
}
# stage's availability zones
variable "azs" {
  type    = list(any)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
# stage's public subnets
variable "vpc_public_subnets" {
  type    = list(any)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}
# stage's private subnets
variable "vpc_private_subnets" {
  type    = list(any)
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "vpc_additional_private_subnets" {
  type    = list(any)
  default = ["10.1.15.0/24", "10.1.16.0/24"]
}

# stage's database subnets
variable "database_subnets" {
  type    = list(any)
  default = ["10.1.5.0/24", "10.1.6.0/24"]
}


# Owner's name for the private subnets (for the tagging)
variable "owner_private" {
  default = "drona-test-private"
}

variable "owner_database" {
  default = "drona-test-database"
}

# Owner's name for the public subnets
variable "owner_public" {
  default = "drona-test-public"
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.env
    Name        = var.name
    Project     = var.project
    Owner       = var.project
  }
}

## Managed node_group_name

variable "node_group_role_name" {
  default = "drona-test-worker-role"
}

variable "disk_size" {
  default = "50"
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 5
}

variable "key_pair_name" {
  default = "test-eks-key"

}

variable "ondemand_node_group_name" {
  default = "test-managed-group-ondemand"
}

variable "node_capacity_ondemand" {
  default = "ON_DEMAND"
}

variable "instance_types_ondemand" {
  type = list(any)
  # default = ["m5.large"]
  default = ["t2.xlarge"]
}

# RDS Database name
variable "database_name" {
  type    = string
  default = "drona-db-test"
}

variable "cluster_identifier" {
  type    = string
  default = "drona-test"
}

variable "database_engine" {
  type    = string
  default = "postgres"
}

variable "engine_family" {
  type    = string
  default = "postgres13"
}

variable "database_engine_version" {
  default = "13.4"
}

variable "database_instance_class" {
  default = "db.t3.medium"
}

variable "database_storage_encrypted" {
  default = true
}

variable "storage_type" {
  default = "gp2"
}

variable "allocated_storage" {
  default = "300"
}

variable "database_apply_immediately" {
  default = true
}

variable "database_monitoring_interval" {
  default = 10
}

variable "iam_role_path" {
  description = "The path to the role"
  type        = string
  default     = null
}

variable "master_username" {
  default = "dronatest"
}

variable "master_password" {
  default = "piyushdb"
}

variable "backup_retention_period" {
  default = 7
}

variable "preferred_backup_window" {
  default = "07:00-09:00"
}

variable "db_name" {
  default = "dronadb"
}

