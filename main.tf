terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
  }

  backend "s3" {
    bucket         = "easternlai-terraform-backend"
    key            = "backend.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "tf-backend"
    profile        = "portfolio-stg"
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "portfolio-stg"
}

### Network Resources

#VPC

resource "aws_vpc" "portfolio" {
  cidr_block = "10.0.0.0/16"

  #required for k8 to work properly
  enable_dns_hostnames = true

  tags = {
    Name = "Portfolio"
  }
}

#Subnet

resource "aws_subnet" "portfolio" {
  vpc_id                  = aws_vpc.portfolio.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Portfolio"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id

  tags = {
    Name = "Portfolio"
  }
}

#Route Table

resource "aws_route_table" "portfolio" {
  vpc_id = aws_vpc.portfolio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio.id
  }

  tags = {
    Name = "Portfolio"
  }

}

# Route Table Association

resource "aws_route_table_association" "portfolio" {
  subnet_id      = aws_subnet.portfolio.id
  route_table_id = aws_route_table.portfolio.id
}


# Security Groups

resource "aws_security_group" "common_ports" {
  name = "portfolio_common"
  tags = {
    Name = "Portfolo Common ports"
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#The following ports on the next two security groups can be found in kubernetes docs: https://kubernetes.io/docs/reference/networking/ports-and-protocols/

resource "aws_security_group" "k8_control_plane" {
  name = "control_plane"
  tags = {
    Name = "Portfolo K8 control plane"
  }

  ingress {
    description = "K8 API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube controller manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "worker_nodes" {
  name = "worker_nodes"
  tags = {
    Name = "Worker nodes"
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# necessary for pods to communicate.
resource "aws_security_group" "flannel" {
  name = "flannel"

  tags = {
    Name = "flannel"
  }

  ingress {
    description = "udp backend"
    from_port   = 8285
    to_port     = 8285
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "udp vxlan backend"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

