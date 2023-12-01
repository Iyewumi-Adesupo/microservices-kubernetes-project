output "private-key" {
  value = tls_private_key.keypair.private_key_pem
}

output "key-id" {
  value = aws_key_pair.keypair.id
}

output "ansible-sg" {
  value = aws_security_group.ansible-sg.id
}

output "kube-nodes-sg" {
  value = aws_security_group.kube-nodes-sg.id
}

output "bastion-sg" {
  value = aws_security_group.bastion-sg.id
}