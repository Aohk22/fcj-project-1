resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
  enable_dns_support   = var.dns_support
  enable_dns_hostnames = var.dns_hostnames
}
