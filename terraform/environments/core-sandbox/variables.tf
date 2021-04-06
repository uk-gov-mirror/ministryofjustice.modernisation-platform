variable "region" {
  default = "eu-west-2"
}

variable "aws_account" {
  description = "The AWS account to deploy the code to"
}

variable "container_version" {
  default = "latest"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = "1"
}

variable "opa_app_name" {
  default = "ccms-opa-hub"
}

variable "app_name" {
  default = "ccms-opa18-hub"
}

variable "ami_image_id" {
  description = "EC2 AMI image to run in the ECS cluster"
}

variable "instance_type" {
  description = "EC2 instance type to run in the ECS cluster"
}

variable "db_instance_class" {
  description = "Instance class for database"
}

variable "key_name" {
  description = "Key to access EC2s in ECS cluster"
}

variable "container_cpu" {
  description = "Container instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "container_memory" {
  description = "Container instance memory to provision (in MiB)"
  default     = "1536"
}

variable "wl_mem_args" {
  description = "Java VM Memory Arguments for Weblogic"
}

variable "opa18_app_name" {
  default = "ccms-opa18-hub"
}

variable "opa18_endpoint" {
}

variable "certificate_arn" {
  description = "The certificate for the lb Listener"
}

variable "opa18_app_image" {
  default = ".dkr.ecr.eu-west-2.amazonaws.com/opa18-hub"
}

variable "old_context" {
  default = ""
}

variable "opa_db_user" {
  default = "opahubdb"
}

variable "opa_db_password" {
  default = "2jAP6q6pd0lc"
}

variable "db_snapshot_identifier" {
  description = "Snapshot to build the database from"
}

variable "db_multi_az" {
}

variable "fq_domain_name" {
  default = "opa10.dev.legalservices.gov.uk"
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

// OPA 18 Hub Variables

variable "opahub_password" {
}

variable "wl_password" {
}


variable "hub_container_cpu" {
}

variable "hub_container_memory" {
}

variable "hub_app_count" {
  default = "1"
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
