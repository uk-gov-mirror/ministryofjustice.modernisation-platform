# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Endpoints
# EC2
data "aws_vpc_endpoint_service" "ec2" {
  service = "ec2"
}

# EC2 Messages
data "aws_vpc_endpoint_service" "ec2messages" {
  service = "ec2messages"
}

# SSM
data "aws_vpc_endpoint_service" "ssm" {
  service = "ssm"
}

# SSM Messages
data "aws_vpc_endpoint_service" "ssmmessages" {
  service = "ssmmessages"
}


# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

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
  max_aggregation_interval = "60"
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  vpc_id                   = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-vpc-flow-logs"
    }
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "subnet_sets" {
  for_each = tomap(var.subnet_sets)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

# Add protected CIDR to VPC
resource "aws_vpc_ipv4_cidr_block_association" "protected" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected
}

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "subnets" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.subnet_sets]

  for_each = tomap(local.all_subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Protected Subnets
resource "aws_subnet" "protected" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.protected]

  for_each = tomap(local.expanded_protected_subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# NACLs
resource "aws_network_acl" "default" {
  depends_on = [aws_subnet.subnets]

  for_each = toset(local.nacls)
  vpc_id   = aws_vpc.vpc.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.subnets["${each.key}-${az}"].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.value}"
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

resource "aws_network_acl_rule" "allow_local_network_egress" {
  for_each = toset(local.distinct_subnets_by_key_type)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.subnet_sets[split("-", each.value)[0]]
}
resource "aws_network_acl_rule" "allow_local_network_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.subnet_sets[split("-", each.value)[0]]
}

resource "aws_network_acl_rule" "allow_vpc_endpoint_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 220
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  from_port      = 1024
  to_port        = 65535
  cidr_block     = var.protected
}

resource "aws_network_acl_rule" "allow_vpc_endpoint_egress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 220
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  from_port      = 443
  to_port        = 443
  cidr_block     = var.protected
}

resource "aws_network_acl_rule" "allow_internet_egress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 910
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "allow_internet_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 910
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl" "subnets_protected" {
  depends_on = [aws_subnet.protected]

  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.protected["protected-${az}"].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-Protected"
    },
  )
}
# add rules to protected subnets
resource "aws_network_acl_rule" "base_nacl_rules_for_protected" {
  for_each = local.protected_nacl_rules_with_keys

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# add rules to protected subnets nacl for all local subnet-sets
resource "aws_network_acl_rule" "local_nacl_rules_for_protected_ingress" {
  for_each = {
    for index, subnet in keys(var.subnet_sets) :
    index => var.subnet_sets[subnet]
  }

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = ((each.key + 1) * 10) + 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = "443"
  to_port        = "443"
}
resource "aws_network_acl_rule" "local_nacl_rules_for_protected_egress" {
  for_each = {
    for index, subnet in keys(var.subnet_sets) :
    index => var.subnet_sets[subnet]
  }

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = ((each.key + 1) * 10) + 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = "1024"
  to_port        = "65535"
}

# VPC: Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-internet-gateway"
    },
  )
}

resource "aws_route_table" "route_tables" {
  for_each = tomap(local.all_distinct_route_tables_with_keys)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.value}"
    }
  )
}
resource "aws_route_table_association" "route_table_associations" {
  for_each = tomap(local.all_distinct_route_table_associations)

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value].id
}
resource "aws_route" "public_internet_gateway" {
  for_each = {
    for key, route_table in aws_route_table.route_tables :
    key => route_table
    if substr(key, length(key) - 6, length(key)) == "public"
  }

  route_table_id         = aws_route_table.route_tables[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table" "protected" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-protected"
    }
  )
}
resource "aws_route_table_association" "protected" {
  for_each = aws_subnet.protected

  subnet_id      = each.value.id
  route_table_id = aws_route_table.protected.id
}


# SSM Security Groups
resource "aws_security_group" "ssm_endpoints" {
  for_each = var.subnet_sets

  name        = "${each.key}_SSM"
  description = "Control SSM traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${each.key}_SSM"
    }
  )
}
resource "aws_security_group_rule" "ssm-ingress1" {
  for_each = var.subnet_sets

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.ssm_endpoints[each.key].id

}
# SSM Endpoints
resource "aws_vpc_endpoint" "ssm_interfaces" {
  for_each = toset(local.ssm_endpoints)

  vpc_id            = aws_vpc.vpc.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.protected["protected-${az}"].id
  ]
  security_group_ids = [
    for key, value in var.subnet_sets :
    aws_security_group.ssm_endpoints[key].id
  ]

  private_dns_enabled = true

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

resource "aws_vpc_endpoint" "ssm_s3" {

  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for value in local.all_distinct_route_table_associations :
    aws_route_table.route_tables[value].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-com.amazonaws.eu-west-2.s3"
    }
  )
}


