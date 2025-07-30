locals {
  region = "us-east-1"

  tags = {
    Name      = "devops-challenge"
    terraform = "true"
  }

  #Network definition
  vpc_name = "devops-challenge"
  azs      = ["us-east-1a", "us-east-1b"]
  vpc_cidr = "10.0.0.0/24"

  private_subnets = [
    "10.0.0.0/26", # 10.0.0.0 - 10.0.0.63
    "10.0.0.64/26" # 10.0.0.64 - 10.0.0.127
  ]
  public_subnets = [
    "10.0.0.128/26", # 10.0.0.128 - 10.0.0.191
    "10.0.0.192/26"  # 10.0.0.192 - 10.0.0.255
  ]

}
