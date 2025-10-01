# internet routing
resource "aws_internet_gateway" "terprovd-igw" {
  vpc_id = aws_vpc.terprovd-vpc.id

  tags = {
    Name = "terprovd-igw"
  }
}
resource "aws_route_table" "terprovd-public-rt" {
  vpc_id = aws_vpc.terprovd-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terprovd-igw.id
  }

  tags = {
    Name = "terprovd-public-rt"
  }
}
resource "aws_route_table_association" "terprovd_pub1_assoc" {
  subnet_id      = aws_subnet.terprovd-pub1-subnet.id
  route_table_id = aws_route_table.terprovd-public-rt.id
}
