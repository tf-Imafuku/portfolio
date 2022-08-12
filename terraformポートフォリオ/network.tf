#-----------------
# VPC
#-----------------
resource "aws_vpc" "terraform-vpc" {
  cidr_block                       = "172.16.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}
#-----------------
# subnet
#-----------------
resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-subnet"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "public-1c" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-east-1c"
  cidr_block              = "172.16.11.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-subnet"
    Project = var.project
    Env     = var.environment
    Type    = "public"

  }
}
resource "aws_subnet" "private-1a" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "172.16.20.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-subnet"
    Project = var.project
    Env     = var.environment
    Type    = "private"

  }
}

resource "aws_subnet" "private-1c" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-east-1c"
  cidr_block              = "172.16.21.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-subnet"
    Project = var.project
    Env     = var.environment
    Type    = "private"

  }
}

#-----------------
# route table
#-----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-public-rt"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "public_rt_1a" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public-1a.id
}

resource "aws_route_table_association" "public_rt_1c" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public-1c.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-private-rt"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "private-1a" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private-1a.id
}

resource "aws_route_table_association" "private-1c" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private-1c.id
}

#-----------------
# Internet Gateway
#-----------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    Project = var.project
    Env     = var.environment

  }
}

resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

