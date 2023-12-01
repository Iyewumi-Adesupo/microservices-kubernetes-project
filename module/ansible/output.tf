output "ansible-ip" {
  value = aws_instance.ansible-server.private_ip
}