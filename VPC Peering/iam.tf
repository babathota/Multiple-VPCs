# IAM Role for EC2 to talk to SSM
resource "aws_iam_role" "ssm_role" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the standard SSM Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# The Instance Profile that gets "attached" to the EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2-SSM-Instance-Profile"
  role = aws_iam_role.ssm_role.name
}