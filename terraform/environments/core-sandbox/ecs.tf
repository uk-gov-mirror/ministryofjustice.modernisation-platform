module "member-ecs" {

  source = "../../modules/member-ecs"

  environment             = local.environment
  account_name            = var.account_name
  region                  = "eu-west-2"
  app_name                = "ccms-opa18-hub"
  container_version       = "latest"
  container_cpu           = "512"
  container_memory        = "1536"
  app_count               = "1"
  ami_image_id            = "ami-0491c71e39d336e96"
  instance_type           = "m5.large"
  key_name                = "sandbox-opa"
  endpoint                = "opa.garden-development.modernisation-platform.service.justice.gov.uk"
  cidr_access             = [
                          "81.134.202.29/32",  // MoJ Digital Wifi
                          "35.177.125.252/32", // MoJ VPN Gateway Proxies
                          "35.177.137.160/32", // MoJ VPN Gateway Proxies
                          "10.200.0.0/20",     // Management VPC - Non-Prod bastion
                          "35.176.127.232/32", // Management DMZ Subnet A - London Non-Prod NAT Gateway
                          "35.177.145.193/32", // Management DMZ Subnet B - London Non-Prod NAT Gateway
                          "18.130.39.94/32",   // Management DMC Subnet C - London Non-Prod NAT Gateway
                          ]
  ec2_desired_capacity   = 2
  ec2_max_size           = 3
  ec2_min_size           = 2
  tags_common            = local.tags
}
