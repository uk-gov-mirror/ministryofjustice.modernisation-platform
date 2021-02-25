output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, subnet in aws_subnet.subnets :
    subnet.id
    if substr(key, 0, 15) == "transit-gateway"
  ]
}

output "non_tgw_subnet_arns" {
  description = "Non-Transit Gateway and Protected subnet ARNs"
  value = [
    for key, subnet in aws_subnet.subnets :
    subnet.arn
    if substr(key, 0, 15) != "transit-gateway"
  ]
}

output "non_tgw_subnet_arns_by_set" {
  value = {
    for set, cidr in var.subnet_sets :
    set => {
      for key, subnet in local.expanded_worker_subnets_assocation :
      "${key}-${cidr}" => aws_subnet.subnets[key].arn
      if substr(key, 0, length(set)) == set
    }
  }
}

locals {
  network_acl_refs = { for value in aws_network_acl.default :

    value.tags.Name =>
    {
      arn  = value.arn
      id   = value.id
      name = value.tags.Name
    }
  }
}

output "nacl_refs" {
  value = local.network_acl_refs
}

output "expanded_worker_subnets_assocation" {
  value = local.expanded_worker_subnets_assocation
}
output "expanded_worker_subnets_with_keys" {
  value = local.expanded_worker_subnets_with_keys
}

output "private_route_tables" {
  value = {
    for key, value in local.all_distinct_route_tables_with_keys :
    key => aws_route_table.route_tables[key].id
    if substr(key, length(key) - 6, length(key)) != "public"
  }
}