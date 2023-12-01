#prometheus load balancer
# create prometheus load balancer
resource "aws_lb" "prom-lb" {
  name                       = "prom-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups    = var.security_group
  subnets            = var.subnet_id
  enable_deletion_protection = false

  tags = {
    Name = "prom-lb"
  }
}
# Worker1 Target group attachment
resource "aws_lb_target_group_attachment" "prom-attachment1" {
  target_group_arn = aws_lb_target_group.prom-target-group.arn
  target_id        = var.worker_node1
  port             = 31090
}

# Worker2 Target group attachment
resource "aws_lb_target_group_attachment" "prom-attachment2" {
  target_group_arn = aws_lb_target_group.prom-target-group.arn
  target_id        = var.worker_node2
  port             = 31090
}

# Worker3 Target group attachment
resource "aws_lb_target_group_attachment" "prom-attachment3" {
  target_group_arn = aws_lb_target_group.prom-target-group.arn
  target_id        = var.worker_node3
  port             = 31090
}

# Creating a Load balancer Listener for http access
resource "aws_lb_listener" "prom-alb-listener1" {
  load_balancer_arn = aws_lb.prom-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prom-target-group.arn
}
}
# Creating a Load balancer Listener for https access
resource "aws_lb_listener" "prom-lb-listener-https" {
  load_balancer_arn      = aws_lb.prom-lb.arn
  port                   = "443"
  protocol               = "HTTPS"
  ssl_policy             = "ELBSecurityPolicy-2016-08"
  certificate_arn        = var.certificate_arn
  default_action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.prom-target-group.arn
  }
}

# Creating Target Group
resource "aws_lb_target_group" "prom-target-group" {
  name             = "prom-tg"
  port             = 31090
  protocol         = "HTTP"
  vpc_id           = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}

# create grafana load balancer
resource "aws_lb" "graf-lb" {
  name                       = "graf-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups    = var.security_group
  subnets            = var.subnet_id
  enable_deletion_protection = false

  tags = {
    Name = "graf-lb"
  }
}
# Worker1 Target group attachment
resource "aws_lb_target_group_attachment" "graf-attachment1" {
  target_group_arn = aws_lb_target_group.graf-target-group.arn
  target_id        = var.worker_node1
  port             = 31300
}

# Worker2 Target group attachment
resource "aws_lb_target_group_attachment" "graf-attachment2" {
  target_group_arn = aws_lb_target_group.graf-target-group.arn
  target_id        = var.worker_node2
  port             = 31300
}

# Worker3 Target group attachment
resource "aws_lb_target_group_attachment" "graf-attachment3" {
  target_group_arn = aws_lb_target_group.graf-target-group.arn
  target_id        = var.worker_node3
  port             = 31300
}

# add a load balancer listener for HTTP
resource "aws_lb_listener" "graf-lb-listener" {
  load_balancer_arn = aws_lb.graf-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graf-target-group.arn
  }
}

# Creating a Load balancer Listener for HTTPS
resource "aws_lb_listener" "graf-lb-listener-https" {
  load_balancer_arn      = aws_lb.graf-lb.arn
  port                   = "443"
  protocol               = "HTTPS"
  ssl_policy             = "ELBSecurityPolicy-2016-08"
  certificate_arn        = var.certificate_arn
  default_action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.graf-target-group.arn
  }
}

# Creating Target Group
resource "aws_lb_target_group" "graf-target-group" {
  name             = "graf-tg"
  port             = 31300
  protocol         = "HTTP"
  vpc_id           = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}
