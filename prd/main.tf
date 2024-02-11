locals {
  env    = "prd"
  region = "us-west-1"

  # The number of availability zones will determine how many subnets there are. Do not exceed 4 subnets.
  availability_zones = ["us-west-1a", "us-west-1b"]
  public_subnets     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20, 10.0.48.0/20"]
  private_subnets    = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20, 10.0.112.0/20"]

  # instance type for nodes
  instance_type = "t3.medium"

}

module "k8-infrastructure" {
  source = "../terraform_module"
  env    = local.env
  region = local.region

  #VPC variables
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  availability_zones = local.availability_zones
  instance_type      = local.instance_type
}

