resource "aws_route53_record" "route53_record" {
  provider = aws.core-vpc
  zone_id = "Z07265222EWMP6UAX47QL"
  name    = "opa.garden-development.modernisation-platform.internal"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
