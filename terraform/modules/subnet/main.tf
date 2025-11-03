resource "aws_subnet" "this" {
  availability_zone       = var.az
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip
  name                    = var.name
}
