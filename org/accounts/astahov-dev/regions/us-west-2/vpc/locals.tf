locals {
  vpc_name = "${local.vars_account.environment}-demo-vpc"
  vpc_cidr = "10.0.0.0/16"

  vpc_azs         = ["${local.aws_region}a", "${local.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  tags = {
    ResourceLevelTag = "Demo"
    Confidentiality  = "Unrestricted"
  }
}
