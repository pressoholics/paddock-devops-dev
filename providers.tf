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
    role_arn = "arn:aws:iam::662365294469:role/terraformRole"
  }
  alias = "jam3devops"
}
