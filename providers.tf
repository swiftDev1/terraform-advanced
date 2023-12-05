terraform {

  required_version = "1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "terraform-user"
  region = "us-east-1"

}