
provider "aws" {
  region = "us-east-1"
}

locals {
  endpoint_local_zone = "demo.primary.lindarren.com"
  endpoint_region     = "demo.backup.lindarren.com"
  domain_name    = "lindarren.com."
  app_name       = "demo"
}

resource "aws_route53_health_check" "localzone" {
  fqdn              = local.endpoint_local_zone
  resource_path     = "/"
  type              = "HTTPS"
  port              = 443
  failure_threshold = 5
  request_interval  = 30
  tags = {
    Name = "Health Check for Ingress in Local Zone"
  }
}

resource "aws_route53_health_check" "region" {
  fqdn              = local.endpoint_region
  resource_path     = "/"
  type              = "HTTPS"
  port              = 443
  failure_threshold = 5
  request_interval  = 30
  tags = {
    Name = "Health Check for Ingress in Region"
  }
}

resource "aws_route53_record" "localzone" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "${local.app_name}.${local.domain_name}"
  records         = [local.endpoint_local_zone]
  set_identifier  = "primary"
  type            = "CNAME"
  ttl             = 60
  health_check_id = aws_route53_health_check.localzone.id
  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "region" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "${local.app_name}.${local.domain_name}"
  records         = [local.endpoint_region]
  set_identifier  = "backup"
  type            = "CNAME"
  ttl             = 60
  health_check_id = aws_route53_health_check.region.id
  failover_routing_policy {
    type = "SECONDARY"
  }
}


data "aws_route53_zone" "main" {
  name = local.domain_name
  # name = var.domain_name
}
