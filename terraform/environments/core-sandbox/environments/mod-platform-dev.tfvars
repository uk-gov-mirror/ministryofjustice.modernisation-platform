business_unit                 = "garden"
subnet_set                    = "general"
account_name                  = "core-sandbox"
app_name                      = "ccms-opa18-hub"
certificate_arn               = "arn:aws:acm:eu-west-2:763252494486:certificate/a96697ef-5b34-4a4a-a0c8-f86375d80bbb"
endpoint                      = "opa.garden-development.modernisation-platform.service.justice.gov.uk"
#opahub_password               = "WVwzkB7E4Q4BU!"
#wl_password                   = "j0E3G9lC1rqv"
#hub_app_count                 = 1
ec2_desired_capacity          = 2
ec2_max_size                  = 3
ec2_min_size                  = 2
cidr_access = [
  "81.134.202.29/32",  // MoJ Digital Wifi
  "35.177.125.252/32", // MoJ VPN Gateway Proxies
  "35.177.137.160/32", // MoJ VPN Gateway Proxies
  "10.200.0.0/20",     // Management VPC - Non-Prod bastion
  "35.176.127.232/32", // Management DMZ Subnet A - London Non-Prod NAT Gateway
  "35.177.145.193/32", // Management DMZ Subnet B - London Non-Prod NAT Gateway
  "18.130.39.94/32",   // Management DMC Subnet C - London Non-Prod NAT Gateway
]
db_instance_class      = "db.t3.large"
db_user                = "opahubdb"
db_password            = "2jAP6q6pd0lc"
db_snapshot_identifier = "arn:aws:rds:eu-west-2:411213865113:snapshot:opa18-post-install-new"
db_multi_az            = "true"
