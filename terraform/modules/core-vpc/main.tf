# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Availability Zones
  availability_zones = sort(data.aws_availability_zones.available.names)

  # Subnet types
  subnet_types = ["private", "public", "data", "transit-gateway"]

  # Subnet CIDRs
  subnet_cidrs = cidrsubnets(var.vpc_cidr, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, 4, 4)

  # Subnet types paired with each availability zone
  subnet_types_across_azs = [
    # Create a cartesian product across subnet types, and availability zones
    for index, type in setproduct(local.subnet_types, local.availability_zones) :
    # Key the type, availability zone, CIDR block, and group for each pairing
    zipmap(["type", "az", "cidr", "group"], concat(type, [local.subnet_cidrs[index], var.tags_prefix]))
  ]

  # Rekey subnets so Terraform can track named resource changes rather than rely on count/indice
  subnets_with_keys = {
    for subnet in local.subnet_types_across_azs :
    "${subnet.group}-${subnet.type}-${subnet.az}" => subnet
  }

  # build subnet group type
  subnet_group = distinct([
    for key, subnet in local.subnets_with_keys :
    "${subnet.group}-${subnet.type}"
  ])
  # default rules for subnets
  nacl_rules = [
    { egress : false, action : "allow", protocol : -1, from_port : 0, to_port : 0, rule_num : 910, cidr : "0.0.0.0/0" },
    { egress : true, action : "allow", protocol : -1, from_port : 0, to_port : 0, rule_num : 910, cidr : "0.0.0.0/0" }
  ]

  expanded_rules = toset(flatten([
    for key, value in toset(local.subnet_group) : [
      for rule_key, rule in toset(local.nacl_rules) : {
        key       = value
        egress    = rule.egress
        action    = rule.action
        protocol  = rule.protocol
        from_port = rule.from_port
        to_port   = rule.to_port
        rule_num  = rule.rule_num
        cidr      = rule.cidr
      }
    ]
  ]))
  expanded_rules_with_keys = {
    for rule in local.expanded_rules :
    "${rule.key}-${rule.cidr}-${rule.egress}-${rule.action}-${rule.protocol}-${rule.from_port}-${rule.to_port}-${rule.rule_num}" => rule
  }

}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  # enable_dns_support   = true
  # enable_dns_hostnames = true

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    },
  )
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "default" {
  name = "${var.tags_prefix}-vpc-flow-logs"
}

resource "aws_flow_log" "cloudwatch" {
  iam_role_arn             = var.vpc_flow_log_iam_role
  log_destination          = aws_cloudwatch_log_group.default.arn
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-vpc-flow-logs"
    }
  )
}

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "subnets" {
  for_each = tomap(local.subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = each.key,
      type = each.value.type
    }
  )
}

# NACLs
resource "aws_network_acl" "default" {
  for_each = toset(local.subnet_group)
  vpc_id   = aws_vpc.vpc.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.subnets["${each.key}-${az}"].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = each.value
    },
  )
}

resource "aws_network_acl_rule" "apply_network_map_rules" {
  for_each = local.expanded_rules_with_keys

  network_acl_id = aws_network_acl.default[each.value.key].id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "allow_local_network_ingress" {
  for_each = toset(local.subnet_group)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "allow_local_network_egress" {
  for_each = toset(local.subnet_group)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# VPC: Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-IG"
    },
  )
}

# Route table per type, per AZ (apart from public, which is separate)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public"
    },
  )
}

# Public Internet Gateway route
resource "aws_route" "public_ig" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Non-public route tables
resource "aws_route_table" "private" {
  for_each = {
    for key, value in local.subnets_with_keys :
    key => value
    if value.type != "public"
  }
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = each.key
    }
  )
}
# Route table associations
resource "aws_route_table_association" "default" {
  for_each = local.subnets_with_keys

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = each.value.type == "public" ? aws_route_table.public.id : aws_route_table.private[each.key].id
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "default" {
  for_each = {
    for key, value in local.subnets_with_keys :
    key => value
    if value.type == "public" && var.gateway == "nat"
  }

  vpc = true

  tags = merge(
    var.tags_common,
    {
      Name = "${each.key}-nat"
    },
  )
}

# Public NAT Gateway
resource "aws_nat_gateway" "default" {
  for_each = {
    for key, value in local.subnets_with_keys :
    key => value
    if value.type == "public" && var.gateway == "nat"
  }

  allocation_id = aws_eip.default[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = merge(
    var.tags_common,
    {
      Name = "${each.value.group}-${each.value.az}"
    }
  )
}

# Private routes
resource "aws_route" "private_nat" {
  for_each = {
    for key, value in local.subnets_with_keys :
    key => value
    if value.type != "public" && var.gateway == "nat"
  }

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default["${each.value.group}-public-${each.value.az}"].id
}

resource "aws_route" "private_transit_gateway" {
  for_each = {
    for key, value in local.subnets_with_keys :
    key => value
    if value.type != "public" && var.gateway == "transit"
  }

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}
