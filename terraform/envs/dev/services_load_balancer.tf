resource "aws_lb" "web_load_balancer" {
  name               = "web-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = [module.subnet_pub_1.id, module.subnet_pub_2.id]
}

resource "aws_lb" "fservice_load_balancer" {
  name               = "services-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = [module.subnet_prv_1.id, module.subnet_prv_2.id]
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = module.groups_service_web.tg_arn
  }
}

resource "aws_lb_listener" "fservice_lb_listener" {
  load_balancer_arn = aws_lb.fservice_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{'message':'Please specify path.'}"
      status_code  = 200
    }
  }
}

resource "aws_lb_listener_rule" "fhandle_lbl_rule" {
  listener_arn = aws_lb_listener.fservice_lb_listener.arn
  priority     = 10
  condition {
    path_pattern {
      values = ["/upload/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = module.groups_service_fhandle.tg_arn
  }
}

resource "aws_lb_listener_rule" "fquery_lbl_rule" {
  listener_arn = aws_lb_listener.fservice_lb_listener.arn
  priority     = 20
  condition {
    path_pattern {
      values = ["/query/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = module.groups_service_fquery.tg_arn
  }
}
