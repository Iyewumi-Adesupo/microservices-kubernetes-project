resource "aws_instance" "bastion" {
  ami                           = var.ami
  instance_type                 = var.instance_type
  subnet_id                     = var.subnets
  associate_public_ip_address   = true
  vpc_security_group_ids        = [var.bastion-sg]
  key_name                      = var.key_name
  user_data                     = templatefile("./module/bastion/bastion.sh", {
    keypair                     = var.private_key

  })
  
  tags = {
    Name = var.tag-bastion
  }    
}