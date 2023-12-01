output "vpc_id" {
    value = aws_vpc.vpc.id 
}
output "pub_sub01" {
    value = aws_subnet.pub_sub01.id
}
output "pub_sub02" {
    value = aws_subnet.pub_sub02.id
}
output "pub_sub03" {
    value = aws_subnet.pub_sub03.id
}
output "priv_sub01" {
    value = aws_subnet.priv_sub01.id
}
output "priv_sub02" {
  value = aws_subnet.priv_sub02.id
}
output "priv_sub03" {
  value = aws_subnet.priv_sub03.id
}
output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}