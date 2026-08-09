output "ec2_public_ip" {
  description = "Public IP of the provisioned EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "s3_bucket_name" {
  description = "Name of the provisioned S3 Bucket"
  value       = aws_s3_bucket.app_bucket.id
}