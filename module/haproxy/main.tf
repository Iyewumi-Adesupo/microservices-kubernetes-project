resource "aws_instance" "HAProxy1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id1
  vpc_security_group_ids      = [var.security_group_ids]
  key_name                    = var.key_name

  user_data = templatefile("./module/haproxy/ha-proxy.sh", {
    master1=var.master1,
    master2=var.master2,
    master3=var.master3
  })
  
  tags = {
    name = var.tag-HAProxy1
  }
}

# create HA proxy server
resource "aws_instance" "HAProxy1-backup" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id2
  vpc_security_group_ids      = [var.security_group_ids]
  key_name                    = var.key_name

  user_data = templatefile("./module/haproxy/ha-proxy-backup.sh", {
    master1=var.master1,
    master2=var.master2,
    master3=var.master3
  })
  
  tags = {
    Name = var.tag-HAProxy1-backup
  }
}