terraform {
  required_version = ">= 1.6"
  backend "s3" {
    bucket       = "mandrade-tfstate"
    key          = "backend/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
