resource "aws_iam_user" "this" {
  for_each = toset(local.iam_users)
  name     = each.value
  tags     = local.tags
}

