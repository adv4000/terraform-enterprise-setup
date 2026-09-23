locals {
  vpc_name = "${local.vars_account.environment}-demo-vpc"
  vpc_cidr = "10.1.0.0/16"

  vpc_azs         = ["${local.aws_region}a", "${local.aws_region}b"]
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.3.0/24", "10.1.4.0/24"]

  tags = {
    ResourceLevelTag = "Demo"
    Confidentiality  = "Unrestricted"
  }
}
