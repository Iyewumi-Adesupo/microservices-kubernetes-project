output "worker-nodes-ip" {
  value = aws_instance.worker-nodes.*.private_ip
}
output "worker-nodes-id" {
  value = aws_instance.worker-nodes.*.id
}