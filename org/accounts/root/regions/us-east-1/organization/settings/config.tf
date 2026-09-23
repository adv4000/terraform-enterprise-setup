# This is to set Store Remote State
terraform {
  backend "s3" {
    key          = "org/accounts/root/regions/us-east-1/organization/settings/the.tfstate" # Path from 'git rev-parse --show-prefix'
    bucket       = "astahov-root-terraform-remote-state"                                   # Remote state Bucket name
    region       = "us-west-2"                                                             # Region of Remote State Bucket
    encrypt      = true
    use_lockfile = true
  }
}

# This is to read Current Region and Variables from all Levels
locals {
  pwd          = abspath(path.root)                                                                               # Print Working Directory
  aws_region   = regex("/regions/([^/]+)", local.pwd)[0]                                                          # Read current Region name
  vars_global  = yamldecode(file(replace(local.pwd, "/accounts/.*$/", "var_global.yml")))                         # Read var_global.yml
  vars_account = yamldecode(file(replace(local.pwd, "/(/accounts/[^/]+).*/", "$1/var_account.yml")))              # Read var_account.yml
  vars_region  = yamldecode(file(replace(local.pwd, "/(/accounts/[^/]+/regions/[^/]+).*/", "$1/var_region.yml"))) # Read var_region.yml
}

# This is to set Default Region to deploy and Apply Default Tags
provider "aws" {
  region = local.aws_region # Set Current Region to deploy resources

  default_tags { # Combine all tags from all levels
    tags = merge(
      local.vars_global.tags,
      local.vars_account.tags,
      local.vars_region.tags
    )
  }
}
