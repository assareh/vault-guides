data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.aws.key_name
  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.benchmark.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  tags = {
    env   = var.env
    role  = "bastion"
    owner = var.owner
    ttl   = var.ttl
  }

  user_data = data.template_file.bastion.rendered
}

data "template_file" "bastion" {
  template = file("${path.module}/templates/bastion.tpl")

  vars = {
    env = var.env
  }
}

