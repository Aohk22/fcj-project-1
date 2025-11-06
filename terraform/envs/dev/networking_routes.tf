resource "aws_internet_gateway" "igw_main" {
  vpc_id = module.vpc.id

  tags = {
    Name = "igw_main"
  }
}
resource "aws_route_table" "route_table_public" {
  vpc_id = module.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }

  tags = {
    Name = "route_table_public"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = module.vpc.id

  tags = {
    Name = "route_table_private"
  }
}

resource "aws_route_table_association" "rt_associate_sn_pub_1" {
  subnet_id      = module.subnet_pub_1.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "rt_associate_sn_pub_2" {
  subnet_id      = module.subnet_pub_2.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "terprovd-private-rt-assoc-1" {
  subnet_id      = module.subnet_prv_1.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "terprovd-private-rt-assoc-2" {
  subnet_id      = module.subnet_prv_2.id
  route_table_id = aws_route_table.route_table_private.id
}
