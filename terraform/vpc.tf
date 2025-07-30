module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name            = local.vpc_name
  cidr            = local.vpc_cidr
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  private_subnet_tags = {
    "Name"      = "${local.tags.Name}-private"
    "Type"      = "private"
    "Terraform" = true
  }

  public_subnet_tags = {
    "Name"      = "${local.tags.Name}-public"
    "Type"      = "public"
    "Terraform" = true
  }

  tags = local.tags

}
