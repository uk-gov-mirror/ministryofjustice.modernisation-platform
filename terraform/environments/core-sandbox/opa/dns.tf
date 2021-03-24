resource "aws_route53_record" "route53_record" {
  zone_id = var.zone_id
  name    = var.opa18_endpoint
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = false
  }
}
