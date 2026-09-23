// Uncomment terraform block after s3 bucket has been created and run 'terraform init'
// type 'yes' to copy backend state from local to s3


// ----------------------------------------------
terraform {
  backend "s3" {
    bucket       = "astahov-root-terraform-remote-state" # Bucket name in ROOT account
    key          = "backend/the.tfstate"                 # Path to store state file
    region       = "us-west-2"                           # Region of Bucket
    use_lockfile = true
    encrypt      = true
  }
}
// ----------------------------------------------


provider "aws" {
  region = "us-west-2" # Region where to create resources
}
