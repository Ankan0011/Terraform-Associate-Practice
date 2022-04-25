terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.6.0"
    }
  }
}

provider "aws" {
  shared_config_files = ["/Users/ankanghosh/.aws/config"]
  shared_credentials_files = ["/Users/ankanghosh/.aws/credentials"]
  profile = "default"
}