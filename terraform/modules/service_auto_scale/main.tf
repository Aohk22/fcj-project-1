// user provided:
// - load balancer listener rules.
// - load balancer.
resource "aws_lb_target_group" "this_lbtg" {
  name     = var.tg_name
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.tg_vpc_id
  deregistration_delay = var.tg_dereg_delay

  health_check {
    path                = var.hc_path
    port                = var.hc_port
    protocol            = var.hc_protocol
    matcher             = var.hc_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  dynamic "stickiness" {
    for_each = var.tg_stickiness == null ? [] : [var.tg_stickiness]
    content {
      type            = stickiness.value.type
      enabled         = stickiness.value.enabled
      cookie_duration = stickiness.value.cookie_duration
    }
  }
}

resource "aws_autoscaling_group" "this_asg" {
  name                = var.asg_name
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  target_group_arns   = [aws_lb_target_group.this_lbtg.arn]
  vpc_zone_identifier = var.asg_subnet_ids
  launch_template {
    id      = var.asg_lt_id
    version = "$Latest"
  }
}

