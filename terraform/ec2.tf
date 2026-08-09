# Retrieve latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Deploy SSH Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "tech-challenge3-deployer-key"
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.deployer_key.key_name
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name        = "tech-challenge-3-web-server"
    Environment = var.environment
  }
}