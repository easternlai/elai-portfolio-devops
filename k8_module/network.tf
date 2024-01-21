resource "aws_vpc" "portfolio" {
  cidr_block = "10.0.128.0/17"

  #required for k8 to work properly
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-portfolio-${var.region}"
  }
}

#Subnet

resource "aws_subnet" "portfolio" {
  for_each                = toset(var.availability_zones)
  availability_zone_id    = each.key
  vpc_id                  = aws_vpc.portfolio.id
  cidr_block              = var.subnet_cidrs[index(var.availability_zones, each.key)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-portfolio-${each.key}"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id

  tags = {
    Name = "${var.env}-portfolio-${var.region}"
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
    Name = "${var.env}-portfolio-${var.region}"
  }

}

# Route Table Association

resource "aws_route_table_association" "portfolio" {
  for_each       = aws_subnet.portfolio
  subnet_id      = each.value.id
  route_table_id = aws_route_table.portfolio.id
}


# Security Groups

resource "aws_security_group" "common_ports" {
  vpc_id = aws_vpc.portfolio.id
  name   = "${var.env}-portfolio-${var.region}-common"
  tags = {
    Name = "${var.env}-portfolio-${var.region}-common"
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
    cidr_blocks = [var.ssh_ip]
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
  vpc_id = aws_vpc.portfolio.id
  name   = "${var.env}-portfolio-${var.region}-control-plane"
  tags = {
    Name = "${var.env}-portfolio-${var.region}-control-plane"
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
  vpc_id = aws_vpc.portfolio.id
  name   = "${var.env}-portfolio-${var.region}-worker"
  tags = {
    Name = "${var.env}-portfolio-${var.region}-worker"
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
