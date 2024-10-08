# module "s3_bucket_access_logs" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket                         = "${var.tags.project}-access-logs-${var.tags.environment}-"
#   acl                            = "log-delivery-write"
#   control_object_ownership       = true
#   object_ownership               = "ObjectWriter"
#   attach_elb_log_delivery_policy = true # Required for ALB logs
#   attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

#   force_destroy = true
#   versioning = {
#     enabled = false
#   }
# }

# resource "aws_s3_bucket" "s3-bucket" {
#   bucket = "bucket-name-dev"
# }

#############################################################################################################
#                                           S3 Bucket Policy Update                                         #
#############################################################################################################

# S3 Bucket claims-moj-services-${var.tags.environment} already exist therefore only updating its permissions
# Giving access to Origin Access Identity of CloudFront to only access gh-pages directory from S3 Bucket


resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = "bucket-name-dev"
  policy = data.aws_iam_policy_document.s3-bucket-policy-document.json
}

data "aws_iam_policy_document" "s3-bucket-policy-document" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.oai_distribution.iam_arn
      ]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::bucket-name-dev/gh-pages/*"
    ]
  }
}
