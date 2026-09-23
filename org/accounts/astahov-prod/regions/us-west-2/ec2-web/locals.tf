locals {
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_detail.vpc_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.vpc_detail.public_subnets
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.vpc_detail.private_subnets

  instance_type = "t3.micro"

  tags = {
    Project        = "Demo Web Server in ASG"
    ResourceTAGKEY = "TAGVALUE"
  }
}
