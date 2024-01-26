locals {
  env    = "stg"
  region = "us-west-2"

  # The number of availability zones will determine how many subnets there are. Do not exceed 4 subnets.
  availability_zones = ["us-west-2a", "us-west-2b"]
  public_subnets     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20, 10.0.176.0/20"]
  private_subnets    = ["10.0.192.0/20", "10.0.208.0/20", "10.0.224.0/20, 10.0.240.0/20"]


}

module "k8-infrastructure" {
  source = "../terraform_module"
  env    = local.env
  region = local.region

  #VPC variables
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  availability_zones = local.availability_zones

}

