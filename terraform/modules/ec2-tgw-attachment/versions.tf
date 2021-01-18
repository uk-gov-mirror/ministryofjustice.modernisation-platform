terraform {
  required_version = ">= 0.14.4"
  required_providers {
    aws = {
      version = ">= 3.23.0"
      source  = "hashicorp/aws"
    }
    time = {
      version = ">= 0.6.0"
      source  = "hashicorp/time"
    }
  }
}
