# Application Load Balancer for Web Servers
resource "aws_lb" "websrvr-lb" {
  name               = "websrvr-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websrvr-lb-sg.id]
  subnets = [
    aws_subnet.terprovd-pub1-subnet.id,
    aws_subnet.terprovd-pub2-subnet.id
  ]
}
resource "aws_lb_listener" "websrvr-lb-l" {
  load_balancer_arn = aws_lb.websrvr-lb.arn
  port              = 80
  protocol          = "HTTP" # idealy HTTPS

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.websrvr-lb-tg.arn
  }
}
resource "aws_lb_target_group" "websrvr-lb-tg" {
  name     = "websrvr-lb-tg"
  port     = 80 # this is the port for the target service
  protocol = "HTTP"
  vpc_id   = aws_vpc.terprovd-vpc.id
}
resource "aws_autoscaling_group" "websrvr-asg" {
  name              = "websrvr-asg"
  max_size          = 1
  min_size          = 1
  desired_capacity  = 1
  target_group_arns = [aws_lb_target_group.websrvr-lb-tg.arn]
  vpc_zone_identifier = [
    aws_subnet.terprovd-pub1-subnet.id,
    aws_subnet.terprovd-pub2-subnet.id
  ]
  launch_template {
    id      = aws_launch_template.web-server-lt.id
    version = "$Latest"
  }
}


# Application Load Balancer for File Processing Services and Query Services
resource "aws_lb" "services-lb" {
  name               = "services-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.services-lb-sg.id]
  subnets = [
    aws_subnet.terprovd-prv1-subnet.id,
    aws_subnet.terprovd-prv2-subnet.id
  ]
}
resource "aws_lb_listener" "services-lb-l" {
  load_balancer_arn = aws_lb.services-lb.arn
  port              = 80
  protocol          = "HTTP" # idealy HTTPS

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.querysrvc-lb-tg.arn
  }
}
resource "aws_lb_target_group" "procsrvc-lb-tg" {
  name     = "procsrvc-lb-tg"
  port     = 6969 # port of the target service
  protocol = "HTTP"
  vpc_id   = aws_vpc.terprovd-vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "6969"
    interval = 30
    timeout  = 4
  }
}
resource "aws_lb_target_group" "querysrvc-lb-tg" {
  name     = "querysrvc-lb-tg"
  port     = 7070 # port of the target service
  protocol = "HTTP"
  vpc_id   = aws_vpc.terprovd-vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "7070"
    interval = 30
    timeout  = 4
  }
}
resource "aws_lb_listener_rule" "services-lb-l-rule" {
  listener_arn = aws_lb_listener.services-lb-l.arn
  priority     = 10
  condition {
    path_pattern {
      values = ["/process/"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.procsrvc-lb-tg.arn
  }
}
resource "aws_autoscaling_group" "procsrvc-asg" {
  name              = "procsrvc-asg"
  max_size          = 1
  min_size          = 1
  desired_capacity  = 1
  target_group_arns = [aws_lb_target_group.procsrvc-lb-tg.arn]
  vpc_zone_identifier = [
    aws_subnet.terprovd-prv1-subnet.id,
    aws_subnet.terprovd-prv2-subnet.id
  ]
  launch_template {
    id      = aws_launch_template.processing-service-lt.id
    version = "$Latest"
  }
}
# no autoscaling for query service
# query service in different AZs
resource "aws_lb_target_group_attachment" "services-lb-tg-attachment-1" {
  target_group_arn = aws_lb_target_group.querysrvc-lb-tg.arn
  target_id        = aws_instance.query-srvc-aza-ec2.id
  port             = 7070
}
resource "aws_lb_target_group_attachment" "services-lb-tg-attachment-2" {
  target_group_arn = aws_lb_target_group.querysrvc-lb-tg.arn
  target_id        = aws_instance.query-srvc-azb-ec2.id
  port             = 7070
}
