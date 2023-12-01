# creating LB Target group
resource "aws_lb_target_group" "prod-target-group" {
  name     = "prod-tg"
  port     = 30002
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}

# creating prod application load balancer
resource "aws_lb" "alb-prod" {
  name               = "alb-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group
  subnets            = var.subnet_id
  enable_deletion_protection = false
  tags = {
    Name = var.tag-prod-alb
  }
}

#Creating Load balancer listener for HTTP
resource "aws_lb_listener" "prod-http" {
  load_balancer_arn = aws_lb.alb-prod.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-target-group.arn
  }
}

#Creating prod Load balancer listener for HTTPs
resource "aws_lb_listener" "https-prod" {
  load_balancer_arn = aws_lb.alb-prod.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-target-group.arn
}
}
# creating stage LB Target group
resource "aws_lb_target_group" "stage-target-group" {
  name     = "stage-tg"
  port     = 30001
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}

#creating stage application load balancer
resource "aws_lb" "stage-alb" {
  name               = "stage-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group
  subnets            = var.subnet_id
  enable_deletion_protection = false
  tags = {
    Name = var.tag-stage-alb
  }
}

#Creating  stage Load balancer listener for HTTP
resource "aws_lb_listener" "stage-http" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-target-group.arn
  }
}

#Creating stage Load balancer listener for HTTPs
resource "aws_lb_listener" "https-stage" {
  load_balancer_arn = aws_lb.stage-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-target-group.arn
  }
}
#creating lb tagrget group for prod
resource "aws_lb_target_group_attachment" "prod-attachmt1" {
  target_group_arn = aws_lb_target_group.prod-target-group.arn
  target_id        = var.worker_node1
  port             = 30002
}
resource "aws_lb_target_group_attachment" "prod-attachmt2" {
  target_group_arn = aws_lb_target_group.prod-target-group.arn
  target_id        = var.worker_node2
  port             = 30002
}
resource "aws_lb_target_group_attachment" "prod-attachmt3" {
  target_group_arn = aws_lb_target_group.prod-target-group.arn
  target_id        = var.worker_node3
  port             = 30002
}
#creating lb tagrget group for stage
resource "aws_lb_target_group_attachment" "stage-attachmt1" {
  target_group_arn =aws_lb_target_group.stage-target-group.arn
  target_id        = var.worker_node1
  port             = 30001
}
resource "aws_lb_target_group_attachment" "stage-attachmt2" {
  target_group_arn = aws_lb_target_group.stage-target-group.arn
  target_id        = var.worker_node2
  port             = 30001
}
resource "aws_lb_target_group_attachment" "stage-attachmt3" {
  target_group_arn = aws_lb_target_group.stage-target-group.arn
  target_id        = var.worker_node3
  port             = 30001
}