locals {
  env                = "stg"
  region             = "us-west-2"
  subnet_cidrs       = ["10.0.128.0/26", "10.0.128.64/26", "10.0.128.128/26", "10.0.128.192/26"] #Must exceed availability zones
  availability_zones = ["usw2-az1", "usw2-az2", "usw2-az3"]                                      #Count of list will determine number of k8 worker nodes.
  ubuntu_ami         = "ami-008fe2fc65df48dac"
  ssh_ip             = "135.180.75.93/32" #IP address for local system


}

module "k8-infrastructure" {
  source = "../k8_module"
  env    = local.env
  region = local.region

  #VPC variables
  subnet_cidrs       = local.subnet_cidrs
  availability_zones = local.availability_zones

  #EC2 variables
  ubuntu_ami = local.ubuntu_ami
  ssh_ip     = local.ssh_ip

}

