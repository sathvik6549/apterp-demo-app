provider "aws" {
  region = "us-east-1"
}

# 1. Create VPC
resource "aws_vpc" "apterp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "apterp-vpc"
  }
}

# 2. Create Public Subnet with auto-assign public IP
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.apterp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "apterp-public-subnet"
  }
}

# 3. Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.apterp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "apterp-private-subnet"
  }
}

# 4. Create Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.apterp_vpc.id

  tags = {
    Name = "apterp-igw"
  }
}

# 5. Create Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.apterp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "apterp-public-rt"
  }
}

# 6. Associate Route Table to Public Subnet
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Create Security Group (Allow SSH and HTTP)
resource "aws_security_group" "sg_apterp" {
  name        = "apterp-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.apterp_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["68.58.218.60/32"]  # Replace YOUR_IP with your public IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "apterp-sg"
  }
}

# 8. Launch EC2 Instance in Public Subnet
resource "aws_instance" "apterp_ec2" {
  ami                         = "ami-0c2b8ca1dad447f8a"  # Amazon Linux 2 (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_apterp.id]
  associate_public_ip_address = true
  key_name                   = "apterp"  # Replace with your key pair

  tags = {
    Name = "apterp-webserver"
  }
}

