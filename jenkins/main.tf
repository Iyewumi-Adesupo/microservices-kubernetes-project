provider "aws" {
  region  = "eu-west-3"
  profile = "euteam-2"
}
locals {
  name = "sskpuaeut2"
}
#create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name = "${local.name}-vpc"
  }
}
#create public subnet 1
resource "aws_subnet" "pub_sub01" {
  vpc_id                = aws_vpc.vpc.id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}_pub_sub01"
  }
}
#create public subnet 2
resource "aws_subnet" "pub_sub02" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = "10.0.2.0/24"
  availability_zone        = "eu-west-3b"
  map_public_ip_on_launch  = true
  tags = {
    Name = "${local.name}-pub_sub02"
  }
}
#create public subnet 3
resource "aws_subnet" "pub_sub03" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = "10.0.3.0/24"
  availability_zone        = "eu-west-3c"
  map_public_ip_on_launch  = true
  tags = {
    Name = "${local.name}-pub_sub02"
  }
}
#create private subnet 1
resource "aws_subnet" "priv_sub01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${local.name}-priv_sub01"
  }
}
#create private subnet 2
resource "aws_subnet" "priv_sub02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-3b"
  tags = {
    Name = "${local.name}-priv_sub02"
  }
}
#create private subnet 3
resource "aws_subnet" "priv_sub03" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-west-3c"
  tags = {
    Name = "${local.name}-priv_sub03"
  }
}
#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-igw"
  }
}
#Creating elastic ip
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.allocation_id
  subnet_id     = aws_subnet.pub_sub01.id

  tags = {
    Name = "${local.name}-nat_gateway"
  }
}
# creating a public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.name}-public_rt"
  }
}
# attaching public subnet 1 to public route table
resource "aws_route_table_association" "public_rt_sub01" {
  subnet_id      = aws_subnet.pub_sub01.id
  route_table_id = aws_route_table.public_rt.id
}
# attaching public subnet 2 to public route table
resource "aws_route_table_association" "public_rt_sub02" {
  subnet_id      = aws_subnet.pub_sub02.id
  route_table_id = aws_route_table.public_rt.id
}
# attaching public subnet 3 to public route table
resource "aws_route_table_association" "public_rt_sub03" {
  subnet_id      = aws_subnet.pub_sub03.id
  route_table_id = aws_route_table.public_rt.id
}
# creating a private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${local.name}-priv_rt"
  }
}
# attaching private subnet 1 to private route table
resource "aws_route_table_association" "private_rt_sub01" {
  subnet_id      = aws_subnet.priv_sub01.id
  route_table_id = aws_route_table.private_rt.id
}
# attaching private subnet 2 to private route table
resource "aws_route_table_association" "private_rt_sub02" {
  subnet_id      = aws_subnet.priv_sub02.id
  route_table_id = aws_route_table.private_rt.id
}
# attaching private subnet 3 to private route table
resource "aws_route_table_association" "private_rt_sub03" {
  subnet_id      = aws_subnet.priv_sub03.id
  route_table_id = aws_route_table.private_rt.id
}
# Security Group for jenkins Server
resource "aws_security_group" "jenkins-sg" {
  name        = "${local.name}-jenkins-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP access"
    from_port   = 8080
    to_port     = 8080
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
    Name = "${local.name}-jenkins-sg"
  }
}
resource "aws_instance" "jenkins" {
  ami                         = "ami-0302f42a44bf53a45"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.pub_sub01.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile3.id
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  key_name                    = aws_key_pair.keypair.id
  user_data                   = local.jenkins_user_data
  tags = {
    Name = "${local.name}-jenkins"
  }
}
# Creating RSA key of size 4096 bits
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "keypair" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "jenkins-keypair.pem"
  file_permission = "600"
}
# Creating keypair
resource "aws_key_pair" "keypair" {
  key_name   = "jenkins-keypair"
  public_key = tls_private_key.keypair.public_key_openssh
}

# Create IAM Policy
resource "aws_iam_role_policy" "ec2_policy3" {
  name = "ec2_policy4"
  role = aws_iam_role.ec2_role3.id
  policy = "${file("${path.root}/ec2-policy.json")}"
}
# Create IAM Role
resource "aws_iam_role" "ec2_role3" {
  name = "ec2_role4"
  assume_role_policy = "${file("${path.root}/ec2-assume.json")}"
}
# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile3" {
  name = "ec2_profile4"
  role = aws_iam_role.ec2_role3.name
}