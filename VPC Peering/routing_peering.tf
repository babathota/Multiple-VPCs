# --- Peering Connections ---
resource "aws_vpc_peering_connection" "a_to_b" {
  vpc_id      = aws_vpc.main["VPC-A"].id
  peer_vpc_id = aws_vpc.main["VPC-B"].id
  auto_accept = true
  tags        = { Name = "Peer-A-to-B" }
}

resource "aws_vpc_peering_connection" "a_to_c" {
  vpc_id      = aws_vpc.main["VPC-A"].id
  peer_vpc_id = aws_vpc.main["VPC-C"].id
  auto_accept = true
  tags        = { Name = "Peer-A-to-C" }
}



# --- ROUTES FOR PRIVATE SUBNETS (VPC A) ---
# Allows Private VPC-A instances to find VPC-B
resource "aws_route" "private_a_to_b" {
  route_table_id            = aws_route_table.private["VPC-A"].id
  destination_cidr_block    = var.vpc_configs["VPC-B"].cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_b.id
}

# Allows Private VPC-A instances to find VPC-C
resource "aws_route" "private_a_to_c" {
  route_table_id            = aws_route_table.private["VPC-A"].id
  destination_cidr_block    = var.vpc_configs["VPC-C"].cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_c.id
}

# --- BACK-ROUTES FOR PRIVATE SUBNETS (VPC B & C) ---
# Allows Private VPC-B instances to find VPC-A
resource "aws_route" "private_b_to_a" {
  route_table_id            = aws_route_table.private["VPC-B"].id
  destination_cidr_block    = var.vpc_configs["VPC-A"].cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_b.id
}

# Allows Private VPC-C instances to find VPC-A
resource "aws_route" "private_c_to_a" {
  route_table_id            = aws_route_table.private["VPC-C"].id
  destination_cidr_block    = var.vpc_configs["VPC-A"].cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_c.id
}