module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "bastion_sg"
  description = "Security group for connecting to the EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


module "bastion-host" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = "bastion-host"
  ami                         = "ami-0a3277ffce9146b74"
  instance_type               = "t2.micro"
  key_name                    = "test-eks-key"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.bastion_security_group.security_group_id]
  associate_public_ip_address = true

  enable_volume_tags = true
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 20
    }
  ]
}
