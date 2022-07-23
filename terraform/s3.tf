resource "template_file" "s3_policy" {
  template = file("./policy.json")

  vars = {
    bucket_name            = "terraform-python-sample-bucket-${terraform.workspace}"
    origin_access_identity = module.cdn.cloudfront_origin_access_identity_ids[0]
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "terraform-python-sample-bucket-${terraform.workspace}"
  acl    = "public-read"

  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
  }

  # Bucket policies
  attach_policy                         = true
  policy                                = template_file.s3_policy.rendered
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
}

resource "aws_s3_bucket_object" "index_page" {
  bucket       = module.s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = "../front/dist/index.html"
  content_type = "text/html"
  etag         = filemd5("../front/dist/index.html")
}
