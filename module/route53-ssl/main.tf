# Route 53 hosted zone
data "aws_route53_zone" "route53_zone" {
  name         = var.domain_name
  private_zone = false
}

#Create route 53 A record for stage
resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain_name1
  type    = "A"
  alias {
    name                   = var.stage_lb_dns_name
    zone_id                = var.stage_lb_zoneid
    evaluate_target_health = false
  }
}

#Create route 53 A record for prod
resource "aws_route53_record" "prod" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain_name2
  type    = "A"
  alias {
    name                   = var.prod_lb_dns_name
    zone_id                = var.prod_lb_zoneid
    evaluate_target_health = false
  }
}
#Create route 53 A record for grafana
resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain-name3
  type    = "A"
  alias {
    name                   = var.grafana_lb_dns_name
    zone_id                = var.grafana_lb_zoneid
    evaluate_target_health = false
  }
}

#Create route 53 A record for prometheus
resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain-name4
  type    = "A"
  alias {
    name                   = var.prometheus_lb_dns_name
    zone_id                = var.prometheus_lb_zoneid
    evaluate_target_health = false
  }
}

#create acm certificate
resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = [var.alt-domain]
  validation_method = "DNS"
  lifecycle {
   create_before_destroy = true
  }
}

#create route53 validation record
resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

#create acm certificate validition
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
certificate_arn  = aws_acm_certificate.acm_certificate.arn
validation_record_fqdns = [for record in aws_route53_record.validation_record  : record.fqdn]
}