resource "aws_iam_role" "ec2" {
  name               = "${local.vars_account.environment}-demo-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  tags               = local.tags
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
