# # for PUBLIC subnets
# resource "aws_network_acl" "public-acl" {
#   vpc_id = aws_vpc.terprovd-vpc.id
#   tags = {
#     Name = "public-subnet-acl"
#   }
# }
# resource "aws_network_acl_rule" "public-acl-ssh-rule" {
#   network_acl_id = aws_network_acl.public-acl.id
#   rule_number    = 199
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 22
#   to_port        = 22
# }
# resource "aws_network_acl_rule" "public-acl-web-rule" {
#   network_acl_id = aws_network_acl.public-acl.id
#   rule_number    = 200
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 80
#   to_port        = 9090
# }
# resource "aws_network_acl_rule" "public-acl-all-rule" {
#   network_acl_id = aws_network_acl.public-acl.id
#   rule_number    = 201
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
# }
# resource "aws_network_acl_rule" "public-acl-egress-rule" {
#   network_acl_id = aws_network_acl.public-acl.id
#   rule_number    = 202
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
# }
# resource "aws_network_acl_association" "public-acl-association-1" {
#   network_acl_id = aws_network_acl.public-acl.id
#   subnet_id      = aws_subnet.terprovd-pub1-subnet.id
# }
# resource "aws_network_acl_association" "public-acl-association-2" {
#   network_acl_id = aws_network_acl.public-acl.id
#   subnet_id      = aws_subnet.terprovd-pub2-subnet.id
# }
#
#
# # for PRIVATE subnets
# resource "aws_network_acl" "private-acl" {
#   vpc_id = aws_vpc.terprovd-vpc.id
# }
# resource "aws_network_acl_rule" "private-acl-procsrvc-rule" {
#   network_acl_id = aws_network_acl.private-acl.id
#   rule_number    = 199
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.terprovd-vpc.cidr_block
#   from_port      = 80
#   to_port        = 9090
# }
# resource "aws_network_acl_rule" "private-acl-usrsrvc-rule" {
#   network_acl_id = aws_network_acl.private-acl.id
#   rule_number    = 200
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.terprovd-vpc.cidr_block
#   from_port      = 80
#   to_port        = 9090
# }
# resource "aws_network_acl_rule" "private-acl-all-rule" {
#   network_acl_id = aws_network_acl.private-acl.id
#   rule_number    = 201
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.terprovd-vpc.cidr_block
# }
# resource "aws_network_acl_rule" "private-acl-egress-rule" {
#   network_acl_id = aws_network_acl.private-acl.id
#   rule_number    = 202
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = aws_vpc.terprovd-vpc.cidr_block
# }
# resource "aws_network_acl_association" "private-acl-association-1" {
#   network_acl_id = aws_network_acl.private-acl.id
#   subnet_id      = aws_subnet.terprovd-prv1-subnet.id
# }
# resource "aws_network_acl_association" "private-acl-association-2" {
#   network_acl_id = aws_network_acl.private-acl.id
#   subnet_id      = aws_subnet.terprovd-prv2-subnet.id
# }
