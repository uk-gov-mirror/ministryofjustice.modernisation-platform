output "vpcs" {
  value = {
    for key in keys(local.networking) :
    key => {
      vpc_id                 = module.vpc[key].vpc_id
      vpc_cidr = module.vpc[key].vpc_cidr
    }
  }
}

output "live_data_vpc_cidr" {
  value = module.vpc["live_data"].vpc_cidr
}

output "non_live_data_vpc_cidr" {
  value = module.vpc["non_live_data"].vpc_cidr
}
