# project account provider; default/implicit
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

# project account provider; explicit
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
  alias = "project-account"
}

# project account provider; us-east-1 region
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = var.role_arn
  }
  alias = "us-east-1"
}

# Jam3 central devops account provider
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::152901669089:role/Jam3DevOpsDNSZoneAdminRole"
  }
  alias = "jam3devops"
}
