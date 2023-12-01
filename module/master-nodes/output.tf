output "master-nodes-ip" {
  value = aws_instance.master-nodes.*.private_ip
}
output "master-nodes-id" {
  value = aws_instance.master-nodes.*.id
}