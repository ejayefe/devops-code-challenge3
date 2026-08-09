variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region for provisioning resources"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment tag"
}

variable "public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to public SSH key for EC2 key pair"
}