variable "region" {
  type        = string
  description = "AWS region"
}

variable "env" {
  type        = string
  description = "The environment for this deployment (prd/stg)."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["usw2-az1", "usw2-az2", "usw2-az3"]
  description = "List of availability zones."
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of subnets."
}

variable "ubuntu_ami" {
  type        = string
  description = "AWS AMI id for nodes."
  default     = "ami-008fe2fc65df48dac"
}

variable "ssh_ip" {
  type        = string
  description = "IP address for local admin system."
}

variable "control_plane_nodes" {
  type = map(string)
  default = {
    instance_type = "t2.medium"
    volume_size   = "20"
  }
  description = "Specs for control plane node."
}

variable "worker_nodes" {
  type = map(string)
  default = {
    instance_type = "t2.micro"
    volume_size   = "10"
  }
  description = "Specs for worker nodes."
}
