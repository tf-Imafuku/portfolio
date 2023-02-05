#-------------
# key pair
#-------------
resource "aws_key_pair" "keypair" {
  key_name   = ""
  public_key = file("./src/terraform-dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}

#-------------
# EC2
#-------------

resource "aws_instance" "terraform-bastion-ec2" {
  ami                         = "ami-090fa75af13c156b4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-1a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.terraform_bastion_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name

  tags = {
    Name    = "${var.project}-${var.environment}-bastion-ec2"
    Project = var.project
    Env     = var.environment
    Type    = "bastion"
  }
}
