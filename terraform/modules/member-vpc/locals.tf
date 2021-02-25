locals {
  availability_zones = sort(data.aws_availability_zones.available.names)

  protected_subnet_nacl_indexes = [310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330]

  # Network AccessControlList rules (NACL's)
  nacl_rules = [
    { egress = false, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 810, cidr = "10.0.0.0/8" },
    { egress = false, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 820, cidr = "172.16.0.0/12" },
    { egress = false, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 830, cidr = "192.168.0.0/16" },
    { egress = true, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 810, cidr = "10.0.0.0/8" },
    { egress = true, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 820, cidr = "172.16.0.0/12" },
    { egress = true, action = "deny", protocol = -1, from_port = 0, to_port = 0, rule_num = 830, cidr = "192.168.0.0/16" }
  ]
  nacls = distinct([
    for key, subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])

  # All subnets (TGW and worker subnets)
  # Combines all Map objects
  all_subnets_with_keys = merge(
    local.expanded_tgw_subnets_with_keys,
    local.expanded_worker_subnets_with_keys, 
  )

  # Transit Gateway subnets
  # Output: List of Maps
  expanded_tgw_subnets = [
    for index, cidr in cidrsubnets(var.vpc_cidr, 2, 2, 2) : {
      key  = "transit-gateway"
      cidr = cidr
      az   = local.availability_zones[index]
      type = "transit-gateway"
    }
  ]

  # Creates map(key:value) for Transit Gateway subnets
  # Output: Map
  expanded_tgw_subnets_with_keys = {
    for subnet in local.expanded_tgw_subnets :
    "${subnet.key}-${subnet.az}" => subnet
  }

  # Protected subnets (Used by the platform only)
  #
  # Input data: var.subnet_set {protected: 10.232.0.0/23}
  # Output data: 
  #  tolist([
  #  "10.232.0.0/25",
  #  "10.232.0.128/25",
  #  "10.232.1.0/25",
  #  ])
  expanded_protected_subnets = [
    for index, cidr in cidrsubnets(var.protected, 2, 2, 2) : {
      key  = "protected"
      cidr = cidr
      az   = local.availability_zones[index]
      type = "protected"
    }
  ]
  expanded_protected_subnets_with_keys = {
    for subnet in local.expanded_protected_subnets :
    "${subnet.key}-${subnet.az}" => subnet
  }

  # expanded worker subnets (public/private/data)
  #
  # Input data: var.subnet_set {general: 10.233.8.0/21}
  # Output data: 
  #  tolist([
  #  "10.233.8.0/24",
  #  "10.233.9.0/24",
  #  "10.233.10.0/24",
  #   ]),
  #  tolist([
  #  "10.233.11.0/25",
  #  "10.233.11.128/25",
  #  "10.233.12.0/25",
  #   ]),
  #  tolist([
  #  "10.233.12.128/25",
  #  "10.233.13.0/25",
  #  "10.233.13.128/25",
  #  ]),
  expanded_worker_subnets = {
    for key, subnet_set in var.subnet_sets :
    key => chunklist(cidrsubnets(subnet_set, 3, 3, 3, 4, 4, 4, 4, 4, 4), 3)
  }
  
  # expanded_worker_subnets_with_keys
  #
  # Input data: local.expanded_worker_subnets_assocation
  # Output data: 
  #   {
  #    general-public-eu-west-2b  = {
  #        + az    = "eu-west-2b"
  #        + cidr  = "10.233.11.128/25"
  #        + group = "general"
  #        + key   = "general"
  #        + type  = "public"
  #      }
  #    + general-public-eu-west-2c  = {
  #        + az    = "eu-west-2c"
  #        + cidr  = "10.233.12.0/25"
  #        + group = "general"
  #        + key   = "general"
  #        + type  = "public"
  #   }
  expanded_worker_subnets_with_keys = {
    for subnet in local.expanded_worker_subnets_assocation :
    "${subnet.key}-${subnet.type}-${subnet.az}" => subnet
  }

  # expanded_worker_subnets_assocation
  #
  # Input data: local.expanded_worker_subnets 
  # Output data: 
  # [
  #    + {
  #        + az    = "eu-west-2a"
  #        + cidr  = "10.233.16.0/24"
  #        + group = "delius"
  #        + key   = "delius"
  #        + type  = "private"
  #      },
  #    + {
  #        + az    = "eu-west-2b"
  #       + cidr  = "10.233.17.0/24"
  #        + group = "delius"
  #        + key   = "delius"
  #        + type  = "private"
  #      },
  # ]
  expanded_worker_subnets_assocation = flatten([
    for key, subnet_set in local.expanded_worker_subnets : [
      for set_index, set in subnet_set : [
        for cidr_index, cidr in set : {
          key   = key
          cidr  = cidr
          az    = local.availability_zones[cidr_index]
          type  = set_index == 0 ? "private" : (set_index == 1 ? "public" : "data")
          group = key
        }
      ]
    ]
  ])

  # expanded_worker_subnets_assocation
  # Distinct subnets by key type not including Transit Gateway subnets
  #
  # Input data: local.all_subnets_with_keys 
  # Output data: 
  # [
  #    + "delius-data",
  #    + "delius-private",
  #    + "delius-public",
  #    + "general-data",
  #    + "general-private",
  #    + "general-public",
  #  ]
  distinct_subnets_by_key_type = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])

  # distinct_subnets_by_key_type_excluding_data
  #
  # Output:
  # Distinct subnets by key type not including Transit Gateway or data subnets
  #
  # [
  #    + "delius-private",
  #    + "delius-public",
  #    + "general-private",
  #    + "general-public",
  #  ] 
  distinct_subnets_by_key_type_excluding_data = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway" && subnet.type != "data"
  ])

  all_distinct_route_tables_with_keys = {
    for rt in local.all_distinct_route_tables :
    rt => rt
  }
  # All distinct route tables
  all_distinct_route_tables = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
  ])

  # All distinct route table associations
  all_distinct_route_table_associations = {
    for key, subnet in local.all_subnets_with_keys :
    key => "${subnet.key}-${subnet.type}"
  }

  expanded_rules = toset(flatten([
    for key, value in toset(local.nacls) : [
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

  protected_nacl_rules = toset(flatten([
    for rule_key, rule in toset(local.nacl_rules) : {
      key       = rule_key
      egress    = rule.egress
      action    = rule.action
      protocol  = rule.protocol
      from_port = rule.from_port
      to_port   = rule.to_port
      rule_num  = rule.rule_num
      cidr      = rule.cidr
    }
  ]))
  protected_nacl_rules_with_keys = {
    for rule in local.protected_nacl_rules :
    "${rule.cidr}-${rule.egress}-${rule.action}-${rule.protocol}-${rule.from_port}-${rule.to_port}-${rule.rule_num}" => rule
  }


  # SSM Endpoints (Systems Session Manager)
  ssm_endpoints = [
    data.aws_vpc_endpoint_service.ec2.service_name,
    data.aws_vpc_endpoint_service.ec2messages.service_name,
    data.aws_vpc_endpoint_service.ssm.service_name,
    data.aws_vpc_endpoint_service.ssmmessages.service_name
  ]
  ssm_endpoints_expanded = flatten([
    for app_key, app in var.subnet_sets : [
      for key, endpoint in local.ssm_endpoints : {
        app_name = app_key
        endpoint = endpoint
      }
    ]
  ])
  expanded_ssm_endpoints_with_keys = {
    for item in local.ssm_endpoints_expanded :
    "${item.app_name}-${item.endpoint}" => item
  }

}