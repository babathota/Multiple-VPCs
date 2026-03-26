# Create Security Group for Endpoints
resource "aws_security_group" "ssm_endpoints_sg" {
  for_each = aws_vpc.main
  name     = "${each.key}-ssm-endpoint-sg"
  vpc_id   = each.value.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [each.value.cidr_block] # Only allow traffic from within the VPC
  }
}

# The 3 Mandatory Endpoints for SSM
locals {
  services = ["ssm", "ssmmessages", "ec2messages"]
}

resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = {
    for pair in flatten([
      for vpc_k, vpc_v in aws_vpc.main : [
        for service in local.services : { vpc_key = vpc_k, service = service }
      ]
    ]) : "${pair.vpc_key}-${pair.service}" => pair
  }

  vpc_id              = aws_vpc.main[each.value.vpc_key].id
  service_name        = "com.amazonaws.${var.region}.${each.value.service}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_endpoints_sg[each.value.vpc_key].id]
  private_dns_enabled = true

  # Attach to all private subnets in that VPC
  subnet_ids = [
    for s in aws_subnet.private : s.id if s.vpc_id == aws_vpc.main[each.value.vpc_key].id
  ]
}