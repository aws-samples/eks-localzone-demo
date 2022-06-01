
provider "aws" {
  region = "us-east-1"
}

resource "aws_route53_health_check" "main" {
  fqdn              = aws_apprunner_custom_domain_association.main.domain_name
  resource_path     = var.health_check
  type              = "HTTPS"
  port              = 443
  failure_threshold = 5
  request_interval  = 30

}

resource "aws_route53_record" "failover" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = aws_apprunner_custom_domain_association.multi_region.domain_name
  records         = [aws_apprunner_custom_domain_association.main.domain_name]
  set_identifier  = var.region
  type            = "CNAME"
  ttl             = 60
  health_check_id = aws_route53_health_check.main.id

}