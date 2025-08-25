terraform { required_version = ">= 1.5.0" }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  enable_irsa                    = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      instance_types = var.node_instance_types
      labels         = { workload = "observability" }
    }
  }

  tags = var.tags
}

module "eks_addons" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-addons"
  version = "~> 20.8"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  tags = var.tags
}



