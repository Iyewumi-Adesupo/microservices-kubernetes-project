# RSA key of size 4096 bits
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#creating private key
resource "local_file" "keypair" {
 content = tls_private_key.keypair.private_key_pem
 filename = "keypair.pem"
 file_permission =  "600"
}

#Creating an EC2 keypair
resource "aws_key_pair" "keypair" {
  key_name   = "infra-key"
  public_key = tls_private_key.keypair.public_key_openssh
}

# Security Group for Ansible Server
resource "aws_security_group" "ansible-sg" {
  name        = var.ansible-sg
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
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

  tags = {
    Name = var.ansible-sg
  }
}

# Security Group for kube-nodes
resource "aws_security_group" "kube-nodes-sg" {
  name        = var.kube-nodes-sg
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
   description = "SSH access"
    from_port   = 0
    to_port     = 65535
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
    Name = var.kube-nodes-sg
  }
}

# Security Group for bastion-host
resource "aws_security_group" "bastion-sg" {
  name        = var.bastion-sg
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
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

  tags = {
    Name = var.bastion-sg
  }
}