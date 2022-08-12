
#-------------
# EC2
#-------------

resource "aws_instance" "terraform-web-ec2" {
  ami                         = "ami-090fa75af13c156b4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private-1a.id
  associate_public_ip_address = false
  vpc_security_group_ids = [
    aws_security_group.terraform_web_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name

  tags = {
    Name    = "${var.project}-${var.environment}-web-ec2"
    Project = var.project
    Env     = var.environment
    Type    = "web"
  }
}