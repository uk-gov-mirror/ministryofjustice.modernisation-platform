terraform {
  # `backend` blocks do not support variables, so the bucket name is hard-coded here, although created in the global-resources/s3.tf file.
  backend "s3" {
    bucket  = "modernisation-platform-terraform-state"
    region  = "eu-west-2"
    key     = "environments/terraform.tfstate"
    encrypt = true
  }
}

# Default provider
provider "aws" {
  region = "eu-west-2"
}

# Environments provider
provider "aws" {
  alias  = "environments"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environments_management.root_account_id}:role/${local.environments_management.root_account_role}"
  }
}