module "s3_backend" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.2.0"

  bucket = "mandrade-tfstate"

  force_destroy = false

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Terraform = true
  }
}
