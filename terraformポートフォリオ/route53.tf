#—————---
#Route53
#—————---
#deploy後にお名前ドットコムにnsを登録する必要あり

resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = false
  tags = {
    Name    = "${var.project}-${var.environment}-domain"
    Project = var.project
    Env     = var.environment
  }
}
resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = "blog-elb.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.terraform-alb.dns_name
    zone_id                = aws_lb.terraform-alb.zone_id
    evaluate_target_health = true #health check
  }
}

