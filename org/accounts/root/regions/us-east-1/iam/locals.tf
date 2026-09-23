locals {
  iam_users = [
    "demo-user1",
    "demo-user2",
    "demo-user3",
    "demo-user4"
  ]
  tags = {
    ResourceTagKey = "ResoureTagValue"
    Purpose        = "Demo User"
  }
}
