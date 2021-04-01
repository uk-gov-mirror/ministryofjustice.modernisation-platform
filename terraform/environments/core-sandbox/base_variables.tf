variable "networking" {

  type = list(any)

}

variable "business_unit" {
  type        = string
  default     = "garden"
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}

variable "subnet_set" {
  type        = string
  default     = "general"
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}

variable "account_name" {
  type        = string
  default     = "core-sandbox"
  description = "account name without environment name excluded - can be used to extract environment from workspace name"
}
