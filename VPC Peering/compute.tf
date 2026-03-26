# Fetch the latest Amazon Linux 2023 AMI (Modern Production Standard)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# VPC-A Bastion
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  subnet_id     = aws_subnet.public["VPC-A-pub-0"].id
  
  # FIX: Explicitly request a public IP
  associate_public_ip_address = true
  
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.internal_sg["VPC-A"].id]

  tags = { Name = "VPC-A-Bastion-Public" }
}

# Updated Private EC2s
resource "aws_instance" "private_test" {
  for_each             = var.vpc_configs
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.nano"
  subnet_id            = aws_subnet.private["${each.key}-priv-0"].id
  vpc_security_group_ids = [aws_security_group.internal_sg[each.key].id]
  
  # NEW: Attach the SSM Profile
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = { Name = "${each.key}-Private-Node" }
}