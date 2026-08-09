# IAM Role for EC2
resource "aws_iam_role" "ec2_s3_role" {
  name = "tech-challenge-3-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 Read Policy to IAM Role
resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tech-challenge-3-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}