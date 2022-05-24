provider "aws" {
  region = "us-east-1"
  
}



provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}


module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

#   tenant      = local.tenant
#   environment = local.environment
#   zone        = local.zone

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = "vpc-0c544fbcafdbbb035"
  private_subnet_ids = [
    "subnet-04bfbdb56eab20f3f",
    "subnet-0282d89055cab1760",
    "subnet-0e3d213bfb21127fa",
  ]

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.22"

  # EKS LOCAL ZONE NODE GROUP
  self_managed_node_groups = {
    self_mg_4 = {
      node_group_name      = "self-managed-ondemand"
      instance_type        = "r5d.2xlarge"
      capacity_type        = ""                      # Optional Use this only for SPOT capacity as capacity_type = "spot"
      launch_template_os   = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp2"
          volume_size = "100"
        },
      ]
      enable_monitoring = false
      # AUTOSCALING
      max_size   = "3"
      min_size   = "1"
      subnet_ids = ["subnet-0179a7e06585a551f"] # Mandatory Public or Private Subnet IDs
    },
  }
}