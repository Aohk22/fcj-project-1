resource "aws_route53_zone" "internal_r53_zone" {
  name = "local-api.dev.lan"
  vpc {
    vpc_id = module.vpc.id
  }
  comment = "Private hosted zone for internal services"
}

resource "aws_route53_record" "fservices_record" {
  zone_id = aws_route53_zone.internal_r53_zone.zone_id
  name    = "local-api.dev.lan"
  type    = "A"
  alias {
    name                   = aws_lb.fservice_load_balancer.dns_name
    zone_id                = aws_lb.fservice_load_balancer.zone_id
    evaluate_target_health = true
  }
}

