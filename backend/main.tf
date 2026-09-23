module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket                                 = "astahov-root-terraform-remote-state"
  force_destroy                          = false
  attach_deny_insecure_transport_policy  = true
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true

  versioning = {
    status = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/aws/s3"
      }
      bucket_key_enabled = true
    }
  }

  lifecycle_rule = [
    {
      id                                     = "DELETE-OLD-AFTER-90-DAYS"
      enabled                                = true
      noncurrent_version_expiration          = { days = 90 }
      expiration                             = { expired_object_delete_marker = true }
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = {
    Owner = "ADV-IT"
    CEO   = "Denis Astahov"
  }
}
