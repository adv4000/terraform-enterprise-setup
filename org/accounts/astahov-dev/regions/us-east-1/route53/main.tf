data "aws_route53_zone" "this" {
  name = local.vars_account.public_domain
}
