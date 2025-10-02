# Private Hosted Zone
resource "aws_route53_zone" "system-internal" {
  name = "system.internal"
  vpc {
    vpc_id = aws_vpc.terprovd-vpc.id
  }
  comment = "Private hosted zone for internal services"
}

# Record for the ALB (Alias)
resource "aws_route53_record" "services" {
  zone_id = aws_route53_zone.system-internal.zone_id
  name    = "services.system.internal"
  type    = "A"

  alias {
    name                   = aws_lb.services-lb.dns_name
    zone_id                = aws_lb.services-lb.zone_id
    evaluate_target_health = true
  }
}

