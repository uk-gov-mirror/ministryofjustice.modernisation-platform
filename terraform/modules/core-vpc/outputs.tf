output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in aws_subnet.subnets :
    value.id
    if value.tags.type == "transit-gateway"
  ]
}

output "non_tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in aws_subnet.subnets :
    value.id
    if value.tags.type != "transit-gateway"
  ]
}
