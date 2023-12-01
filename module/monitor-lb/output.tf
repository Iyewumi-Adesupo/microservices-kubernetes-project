output "prometheus-alb-target-group-arn" {
  value = aws_lb_target_group.prom-target-group.arn
}

output "prometheus-dns-name" {
  value = aws_lb.prom-lb.dns_name
}
output "prometheus_lb_arn" {
    value = aws_lb.prom-lb.arn
}

output "prometheus-zone-id" {
  value = aws_lb.prom-lb.zone_id
}
output "grafana-tg-arn" {
  value = aws_lb_target_group.graf-target-group.arn
}
output "grafana-dns-name" {
  value = aws_lb.graf-lb.dns_name
}
output "grafana-zone-id" {
  value = aws_lb.graf-lb.zone_id
}
output "grafana_lb_arn" {
  value = aws_lb.graf-lb.arn
}