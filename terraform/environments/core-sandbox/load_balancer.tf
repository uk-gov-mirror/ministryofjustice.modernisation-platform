resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.shared-public.ids

  security_groups = [aws_security_group.load_balancer_security_group.id]

  tags = local.tags
}

resource "aws_lb_target_group" "target_group" {
  name_prefix          = "opahub"
  port                 = var.server_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.shared.id
  target_type          = "instance"
  deregistration_delay = 30

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path                = var.health_check_path
    healthy_threshold   = "5"
    interval            = "120"
    protocol            = "HTTP"
    unhealthy_threshold = "2"
    matcher             = "200"
    timeout             = "5"
  }

  tags = local.tags
}

# Redirect all port 7001 traffic from the lb to the target group (required for weblogic)
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "allow_hub" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }

  condition {
    path_pattern {
      values = ["/opa/web-determinations/*"]
    }
  }

}

resource "aws_security_group" "load_balancer_security_group" {
  name_prefix = "${var.app_name}-load-balancer-sg"
  description = "controls access to lb"
  vpc_id      = data.aws_vpc.shared.id

  ingress {
    protocol  = "tcp"
    from_port = var.server_port
    to_port   = var.server_port
    cidr_blocks = concat(
      var.cidr_access,
    )
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = concat(
      var.cidr_access,
    )
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0", ]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = local.tags
}
