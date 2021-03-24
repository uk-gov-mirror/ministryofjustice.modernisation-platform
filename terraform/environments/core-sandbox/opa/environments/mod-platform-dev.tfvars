aws_account                   = "sandbox-opa"
opa18_endpoint                = "ccms-opahub-mod-platform.dev.legalservices.gov.uk"
opahub_password               = "WVwzkB7E4Q4BU!"
wl_password                   = "j0E3G9lC1rqv"
hub_app_count                 = 1
ec2_desired_capacity          = 2
ec2_max_size                  = 3
ec2_min_size                  = 2
ami_image_id                  = "ami-0491c71e39d336e96"
instance_type                 = "m5.large"
key_name                      = "sandbox-opa"
hub_container_cpu             = "512"
hub_container_memory          = "1536"
wl_mem_args                   = "-Xms1024m -Xmx1024m"
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
db_snapshot_identifier = "opa18-post-install-new"
db_multi_az            = "true"
