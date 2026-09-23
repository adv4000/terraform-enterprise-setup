################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v6.7.0"

  name               = local.vpc_name
  cidr               = local.vpc_cidr
  azs                = local.vpc_azs
  private_subnets    = local.public_subnets
  public_subnets     = local.private_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = local.tags
}

################################################################################
# VPC Endpoints Module
################################################################################

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "v6.7.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }
  }
  tags = local.tags
}
