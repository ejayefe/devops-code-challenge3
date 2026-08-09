resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "tech-challenge3-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "app-s3-bucket"
    Environment = var.environment
  }
}