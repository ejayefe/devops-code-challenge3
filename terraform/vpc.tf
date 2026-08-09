resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "default-subnet-a"
  }
}