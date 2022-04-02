provider "aws" {
  region = var.region

  access_key = ""
  secret_key = ""
}

module "applications" {
  source = "../../applications"
  env    = var.env
  region = var.region
}