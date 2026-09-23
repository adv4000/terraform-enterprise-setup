data "terraform_remote_state" "vpc" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    key    = "org/accounts/astahov-dev/regions/us-west-2/vpc/the.tfstate" // Object name in the bucket to GET Terraform State
    bucket = "astahov-root-terraform-remote-state"                        // Bucket from where to GET Terraform State
    region = "us-west-2"                                                  // Region where bucket created
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}
