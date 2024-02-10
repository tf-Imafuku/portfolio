#-----------------
# Application Load Balancer 
#-----------------
resource "aws_lb" "terraform-alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.terraform_alb_sg.id
  ]
  subnets = [
    aws_subnet.public-1a.id,
    aws_subnet.public-1c.id
  ]
}
#ALB Listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.virginia_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
  depends_on = [
    aws_acm_certificate_validation.cert_valid
  ]
}
#-----------------
# target group
#-----------------
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.environment}-web-tg"
  port     = "3000"
  protocol = "HTTPS"
  vpc_id   = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-web-tg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_lb_target_group_attachment" "instance" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.terraform-web-ec2.id
}