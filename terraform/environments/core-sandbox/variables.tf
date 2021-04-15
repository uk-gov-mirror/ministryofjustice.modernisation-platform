variable "region" {
  default = "eu-west-2"
}

variable "app_name" {
}

variable "db_instance_class" {
  description = "Instance class for database"
}

variable "endpoint" {
}

variable "certificate_arn" {
  description = "The certificate for the lb Listener"
}

variable "db_snapshot_identifier" {
  description = "Snapshot to build the database from"
}

variable "db_multi_az" {
}

variable "server_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 7001
}

variable "zone_id" {
  default = "true"
}

variable "cidr_access" {
  description = "List of the Cidr block for workspace access"
  type        = list(string)
}

variable "ec2_desired_capacity" {
  description = "Number of EC2s in the cluster"
}

variable "ec2_max_size" {
  description = "Max Number of EC2s in the cluster"
}

variable "ec2_min_size" {
  description = "Min Number of EC2s in the cluster"
}

variable "db_user" {
}

variable "db_password" {
}

variable "health_check_path" {
  default = "/opa/opa-hub/manager"
}

variable "business_unit" {
  type        = string
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}

variable "subnet_set" {
  type        = string
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}

variable "account_name" {
  type        = string
  description = "account name without environment name excluded - can be used to extract environment from workspace name"
}
