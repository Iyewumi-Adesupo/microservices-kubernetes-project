output "HAProxy1-ip" {
  value = aws_instance.HAProxy1.private_ip
}
output "HAProxy1-backup-ip" {
  value = aws_instance.HAProxy1-backup.private_ip
}