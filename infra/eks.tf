# 1. ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "devops-task-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 2. EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  # OLD WAY - Delete these two lines
  # vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets

  # NEW WAY - Add these two lines
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  cluster_endpoint_public_access = true


  # This is important! The module needs to be able to add tags
  # to your default subnets so the AWS Load Balancer can find them.
  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }


  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.micro"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }
  }
}