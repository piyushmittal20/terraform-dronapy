data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_launch_template" "default" {
  name_prefix            = "eks-stage-template"
  description            = "eks-stage-template"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  # }
}


module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = "${var.name}-eks"
  cluster_version                 = "1.21"
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = "false" #
  cluster_endpoint_private_access = "true"
  #cluster_endpoint_private_access_cidrs          = ["10.1.0.0/16"]
  #create_cluster_security_group                  = "true"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  #manage_aws_auth                                = false
  vpc_id      = module.vpc.vpc_id
  enable_irsa = true

  cluster_addons = {
    # coredns = {
    #   resolve_conflicts = "OVERWRITE"
    # }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]


  tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.project
    Name        = var.name
    GithubRepo  = var.git_repo
    GithubOrg   = var.project
  }

  #map_roles = concat(var.map_roles, local.managed_node_role)
  # map_roles    = var.map_roles
  #map_users    = var.map_users
  #map_accounts = var.map_accounts
}

resource "aws_eks_node_group" "ondemand-nodegroup" {
  cluster_name    = "${var.name}-eks"
  node_group_name = var.ondemand_node_group_name
  node_role_arn   = aws_iam_role.managed_node_role.arn
  subnet_ids      = data.aws_subnet_ids.private_subnet.ids
  capacity_type   = var.node_capacity_ondemand
  instance_types  = var.instance_types_ondemand
  disk_size       = var.disk_size
  tags = {
    Terraform   = "true"
    Environment = var.env
    Project     = var.project
    Owner       = var.project
    Name        = var.name
    GithubRepo  = var.git_repo
    GithubOrg   = var.project
  }
  labels = {
    capacity = "ondemand"
  }
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  remote_access {
    ec2_ssh_key = var.key_pair_name
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    module.eks
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = "${var.name}-eks"
  addon_name   = "coredns"
}

data "aws_subnet_ids" "private_subnet" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "cidr-block"
    values = var.vpc_private_subnets
  }
  depends_on = [
    module.vpc
  ]
}


resource "aws_iam_role" "managed_node_role" {
  name = var.node_group_role_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

locals {
  managed_node_role = [{
    rolearn  = aws_iam_role.managed_node_role.arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
