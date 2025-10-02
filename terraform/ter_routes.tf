# routes PUBLIC
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
resource "aws_route_table_association" "terprovd-public-rt-assoc-1" {
  subnet_id      = aws_subnet.terprovd-pub1-subnet.id
  route_table_id = aws_route_table.terprovd-public-rt.id
}
resource "aws_route_table_association" "terprovd-public-rt-assoc-2" {
  subnet_id      = aws_subnet.terprovd-pub2-subnet.id
  route_table_id = aws_route_table.terprovd-public-rt.id
}

# routes PRIVATE
resource "aws_route_table" "terprovd-private-rt" {
  vpc_id = aws_vpc.terprovd-vpc.id
  tags = {
    Name = "terprovd-private-rt"
  }
}
resource "aws_route_table_association" "terprovd-private-rt-assoc-1" {
  subnet_id      = aws_subnet.terprovd-prv1-subnet.id
  route_table_id = aws_route_table.terprovd-private-rt.id
}
resource "aws_route_table_association" "terprovd-private-rt-assoc-2" {
  subnet_id      = aws_subnet.terprovd-prv2-subnet.id
  route_table_id = aws_route_table.terprovd-private-rt.id
}
