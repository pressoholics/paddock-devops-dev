terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 3.0"
      configuration_aliases = [aws.project-account, aws.us-east-1, aws.jam3devops]
    }
  }
}
