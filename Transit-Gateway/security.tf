# --- Network ACL for VPC A ---
resource "aws_network_acl" "vpc_a_nacl" {
  vpc_id = aws_vpc.main["VPC-A"].id

  ingress {
    protocol = "-1"         # ICMP
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 0
    to_port    = 0  

  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# --- Security Group for Ping/SSH ---
resource "aws_security_group" "internal_sg" {
  for_each = aws_vpc.main
  vpc_id   = each.value.id
  name     = "${each.key}-sg"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}