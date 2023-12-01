# Create Ansible Server
resource "aws_instance" "ansible-server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  user_data                   = templatefile("./module/ansible/user-data.sh", {
    private-key         = var.priv-key,
    HAproxy1-IP         = var.HAproxy1-IP,
    HAproxy2-IP         = var.HAproxy2-IP,
    master1-IP          = var.master1-IP,
    master2-IP          = var.master2-IP,
    master3-IP          = var.master3-IP,
    worker1-IP          = var.worker1-IP,
    worker2-IP          = var.worker2-IP,
    worker3-IP          = var.worker3-IP
  })
 
  tags = {
    name = var.tag-ansible-server
  }
}

#Create null resource to copy playbooks directory into ansible server
resource "null_resource" "copy-playbooks" {
  connection {
    type = "ssh"
    host = aws_instance.ansible-server.private_ip
    user = "ubuntu"
    private_key = var.priv-key
    bastion_host = var.bastion_host
    bastion_user = "ubuntu"
    bastion_private_key = var.priv-key
  }
  provisioner "file" {
    source = "./module/ansible/playbooks"
    destination = "/home/ubuntu/playbooks"
  }
}