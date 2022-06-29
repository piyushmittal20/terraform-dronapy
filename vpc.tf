module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.env-cidr

  azs              = var.azs
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.database_subnets
  #elasticache_subnets = var.elasticache_subnets
  #redshift_subnets    = var.redshift_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  #elasticache_subnet_group_name = var.elastic_cache_subnet_name
  #create_elasticache_subnet_group = true

  create_database_internet_gateway_route = true
  create_database_subnet_route_table     = true



  vpc_flow_log_tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.project
    Name        = var.name
  }
  enable_nat_gateway = true
  single_nat_gateway = true
  #one_nat_gateway_per_az = true


  # Default security group - ingress/egress rules cleared to deny all
  # manage_default_security_group  = true
  # default_security_group_ingress = [{}]
  # default_security_group_egress  = [{}]
  private_subnet_tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.owner_private
    #"kubernetes.io/cluster/test-eks"  = "shared"
    #"kubernetes.io/role/internal-elb" = 1        
    Name = "${var.name}-private"
  }
  database_subnet_tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.owner_database
    Name        = "${var.name}-database"
  }
  public_subnet_tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.owner_public
    #"kubernetes.io/cluster/test-eks" = "shared" 
    #"kubernetes.io/role/elb"         = 1        
    Name = "${var.name}-public"

  }
  #elasticache_subnet_tags = {
  #    Terraform = "true"
  #    Environment = var.environment
  #    Project = var.project
  #    Owner = var.owner_database
  #    Name  = "${var.env}-elasticache"
  #}
  tags = {
    Owner       = var.project
    Environment = var.env
    Name        = var.name
    Project     = var.project
  }
}
