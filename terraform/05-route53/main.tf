
provider "aws" {
  region = "us-east-1"
}

locals {
  alb_local_zone = "k8s-default-wordpres-ed46143e74-19802854.us-east-1.elb.amazonaws.com"
  alb_region     = "k8s-default-wordpres-8d75cd8cec-1419359919.us-east-1.elb.amazonaws.com"
  domain_name    = "lindarren.com."
  app_name       = "demo"
}

resource "aws_route53_health_check" "localzone" {
  fqdn              = local.alb_local_zone
  resource_path     = "/"
  type              = "HTTP"
  port              = 80
  failure_threshold = 5
  request_interval  = 30
  tags = {
    Name = "Health Check for Local Zone ALB"
  }
}


resource "aws_route53_health_check" "region" {
  fqdn              = local.alb_region
  resource_path     = "/"
  type              = "HTTP"
  port              = 80
  failure_threshold = 5
  request_interval  = 30
  tags = {
    Name = "Health Check for Region ALB"
  }
}

resource "aws_route53_record" "localzone" {
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "${local.app_name}.${local.domain_name}"
  records         = [local.alb_local_zone]
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
  records         = [local.alb_region]
  set_identifier  = "backup"
  type            = "CNAME"
  ttl             = 60
  health_check_id = aws_route53_health_check.localzone.id
  failover_routing_policy {
    type = "SECONDARY"
  }
}


data "aws_route53_zone" "main" {
  name = local.domain_name
  # name = var.domain_name
}
