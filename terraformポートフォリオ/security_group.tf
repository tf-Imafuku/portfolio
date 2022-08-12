#-----------------
# Security Group
#-----------------
# 踏み台サーバー セキュリティグループ

resource "aws_security_group" "terraform_bastion_sg" {
  name        = "terraform-bastion-sg"
  description = "terraform-bastion-sg"
  vpc_id      = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-bastion-sg"
    Project = var.project
    Env     = var.environment
  }
}
#22番ポート許可のインバウンドルール
resource "aws_security_group_rule" "bastion_in_ssh" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = [var.MyIP] #自分のIP 

  security_group_id = aws_security_group.terraform_bastion_sg.id
}
#アウトバウンドルール
resource "aws_security_group_rule" "bastion_out_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.terraform_bastion_sg.id

}

#ALB セキュリティグループ
resource "aws_security_group" "terraform_alb_sg" {
  name        = "terraform-alb-sg"
  description = "terraform-alb-sg"
  vpc_id      = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-alb-sg"
    Project = var.project
    Env     = var.environment
  }
}

#80番ポートのインバウンドルール
resource "aws_security_group_rule" "alb_in_http" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.terraform_alb_sg.id
}

#443番ポートのインバウンドルール
resource "aws_security_group_rule" "alb_in_https" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.terraform_alb_sg.id
}

#アウトバウンドルール
resource "aws_security_group_rule" "alb_out_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.terraform_alb_sg.id
}

#webサーバー　セキュリティグループ
resource "aws_security_group" "terraform_web_sg" {
  name        = "terraform-web-sg"
  description = "terraform-web-sg"
  vpc_id      = aws_vpc.terraform-vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-web-sg"
    Project = var.project
    Env     = var.environment
  }
}

#22番ポート許可のインバウンドルール
resource "aws_security_group_rule" "web_in_ssh" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = aws_security_group.terraform_bastion_sg.id

  security_group_id = aws_security_group.terraform_web_sg.id
}

#80番ポートのインバウンドルール
resource "aws_security_group_rule" "web_in_http" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.terraform_alb_sg.id

  security_group_id = aws_security_group.terraform_web_sg.id
}


