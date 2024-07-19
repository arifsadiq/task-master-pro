# CREATE VPC
########################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/task-master-pro-cluster" = "shared"

  }

  public_subnet_tags = {
    "kubernetes.io/cluster/task-master-pro-cluster" = "shared"
    "kubernetes.io/role/elb"               = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/task-master-pro-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "shared"
  }
}

# CREATE EKS CLUSTER
##################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "task-master-pro-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  # EKS Managed Node Group(s)

  eks_managed_node_groups = {
    workernode = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 6
      desired_size = 2
    }
  }


  tags = {
    Name        = "Task-Master-Pro-EKS"
    Environment = "dev"
    Terraform   = "true"
  }
}