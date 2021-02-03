output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in local.expanded_subnets_with_keys :
    aws_subnet.subnets[key].id
    if value.type == "transit-gateway"
  ]
}

output "non_tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in local.expanded_subnets_with_keys :
    aws_subnet.subnets[key].id
    if value.type != "transit-gateway"
  ]
}

output "private_route_tables" {
  value = {
    for key, value in local.expanded_subnets_with_keys :
    key => aws_route_table.private[key].id
    if value.type != "public"
  }
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value = aws_vpc.vpc.cidr_block
}
