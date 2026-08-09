resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "default-subnet-a"
  }
}

# Attach an Internet Gateway to ensure outbound/inbound public internet routing
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_default_vpc.default.id

  tags = {
    Name = "main-igw"
  }
}

# Ensure standard traffic (0.0.0.0/0) routes through the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_default_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_default_subnet.default_az1.id
  route_table_id = aws_route_table.public_rt.id
}