locals {
  ec2_role_name = "${local.vars_account.environment}-demo-ec2-role"
  tags = {
    ResourceTagKey = "ResoureTagValue"
    Purpose        = "Demo Role"
  }
}

