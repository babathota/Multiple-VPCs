resource "aws_ec2_transit_gateway" "main" {
  description = "Prod TGW"

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  multicast_support = "enable"
  dns_support = "enable"
  vpn_ecmp_support = "enable"


  

  tags = {
    Name = "prod-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attach" {

  for_each = aws_vpc.main

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.id

  subnet_ids = [
    aws_subnet.tgw["${each.key}-tgw-0"].id,
    aws_subnet.tgw["${each.key}-tgw-1"].id
  ]

  tags = {
    Name = "${each.key}-tgw-attachment"
  }
}

locals {
  vpc_route_pairs = flatten([
    for src_key, src_val in var.vpc_configs : [
      for dst_key, dst_val in var.vpc_configs : {
        src_vpc = src_key
        dst_vpc = dst_key
        dst_cidr = dst_val.cidr
      }
      if src_key != dst_key
    ]
  ])
}

resource "aws_route" "tgw_routes" {

  for_each = {
    for r in local.vpc_route_pairs :
    "${r.src_vpc}-${r.dst_vpc}" => r
  }

  route_table_id         = aws_route_table.private[each.value.src_vpc].id
  destination_cidr_block = each.value.dst_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc_attach
  ]

}