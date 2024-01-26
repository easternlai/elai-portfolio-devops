resource "aws_vpc" "portfolio" {
  cidr_block = "10.0.128.0/17"

  tags = {
    Name = local.name
  }
}

resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id

  tags = {
    Name = local.name
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones)
  availability_zone = each.key
  vpc_id            = aws_vpc.portfolio.id
  cidr_block        = var.private_subnets[index(var.availability_zones, each.key)]

  tags = {
    Name                                                    = "${local.name}-private"
    "kubernetes.io/role/internal-elb"                       = 1
    "kubernetes.io/cluster/stg-portfolio-us-west-2-cluster" = "shared"
  }
}

resource "aws_subnet" "public" {
  for_each          = toset(var.availability_zones)
  availability_zone = each.key
  vpc_id            = aws_vpc.portfolio.id
  cidr_block        = var.public_subnets[index(var.availability_zones, each.key)]
  # map_public_ip_on_launch = true

  tags = {
    Name                                                    = "${local.name}-public"
    "kubernetes.io/role/elb"                                = 1
    "kubernetes.io/cluster/stg-portfolio-us-west-2-cluster" = "shared"

  }
}

resource "aws_eip" "nat-ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "portfolio" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = {
    Name = local.name
  }

  depends_on = [aws_internet_gateway.portfolio]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.portfolio.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.portfolio.id
  }
  tags = {
    Name = local.name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.portfolio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio.id
  }
  tags = {
    Name = local.name
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

