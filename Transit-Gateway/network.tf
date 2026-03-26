# --- VPCs ---
resource "aws_vpc" "main" {
  for_each             = var.vpc_configs
  cidr_block           = each.value.cidr
  enable_dns_hostnames = true
  tags                 = { Name = "Prod-${each.key}", Env = "Production" }
}

# --- Internet Gateways ---
resource "aws_internet_gateway" "igw" {
  for_each = aws_vpc.main
  vpc_id   = each.value.id
  tags     = { Name = "${each.key}-IGW" }
}

# --- Subnets (Multi-AZ) ---
locals {
  public_subnets = flatten([
    for vpc_key, vpc_val in var.vpc_configs : [
      for i, cidr in vpc_val.public_subnets : {
        vpc_key = vpc_key, cidr = cidr, az = var.azs[i], idx = i
      }
    ]
  ])
  private_subnets = flatten([
    for vpc_key, vpc_val in var.vpc_configs : [
      for i, cidr in vpc_val.private_subnets : {
        vpc_key = vpc_key, cidr = cidr, az = var.azs[i], idx = i
      }
    ]
  ])
    tgw_subnets = flatten([
    for vpc_key, vpc_val in var.vpc_configs : [
      for i, cidr in vpc_val.tgw_subnets : {
        vpc_key = vpc_key
        cidr    = cidr
        az      = var.azs[i]
        idx     = i
      }
    ]
  ])

}

resource "aws_subnet" "public" {
  for_each          = { for s in local.public_subnets : "${s.vpc_key}-pub-${s.idx}" => s }
  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true
  tags              = { Name = "${each.key}", Tier = "Public" }
}

resource "aws_subnet" "private" {
  for_each          = { for s in local.private_subnets : "${s.vpc_key}-priv-${s.idx}" => s }
  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "${each.key}", Tier = "Private" }
}

resource "aws_subnet" "tgw" {
  for_each = { for s in local.tgw_subnets : "${s.vpc_key}-tgw-${s.idx}" => s}

  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.key}"
    Tier = "TGW"
  }
}

# --- NAT Gateways (FIXED aws_eip) ---
resource "aws_eip" "nat" {
  for_each = aws_vpc.main
  domain   = "vpc" # Replaces deprecated vpc = true
  tags     = { Name = "${each.key}-NAT-EIP" }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_vpc.main
  allocation_id = aws_eip.nat[each.key].id
  # References the first public subnet (VPC-A-pub-0, etc)
  subnet_id     = aws_subnet.public["${each.key}-pub-0"].id
  tags          = { Name = "${each.key}-NAT" }
}




# Private Route Tables (One per VPC to point to its NAT Gateway)
resource "aws_route_table" "private" {
  for_each = aws_vpc.main
  vpc_id   = each.value.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = { Name = "${each.key}-private-rt" }
} 

# --- Route Tables & Routes ---
resource "aws_route_table" "public" {
  for_each = aws_vpc.main
  vpc_id   = each.value.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.key].id # Must point to IGW
  }
  
  # (Your peering routes stay here too)
}

resource "aws_route_table" "tgw" {
  for_each = aws_vpc.main

  vpc_id = each.value.id

  tags = {
    Name = "${each.key}-tgw-rt"
  }
}



# Cleaner Public Association
resource "aws_route_table_association" "public" {
  for_each       = { for s in local.public_subnets : "${s.vpc_key}-pub-${s.idx}" => s }
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_key].id
  
}

# Cleaner Private Association
resource "aws_route_table_association" "private" {
  for_each       = { for s in local.private_subnets : "${s.vpc_key}-priv-${s.idx}" => s }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.vpc_key].id
}

resource "aws_route_table_association" "tgw" {

  for_each = {
    for s in local.tgw_subnets :
    "${s.vpc_key}-tgw-${s.idx}" => s
  }

  subnet_id      = aws_subnet.tgw[each.key].id
  route_table_id = aws_route_table.tgw[each.value.vpc_key].id
}