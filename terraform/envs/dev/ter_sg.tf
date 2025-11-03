# security group for ssh
resource "aws_security_group" "ssh" {
  name   = "allow-ssh-sg"
  vpc_id = aws_vpc.terprovd-vpc.id

}
resource "aws_security_group_rule" "ssh-rule-1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
}
# for icmp
resource "aws_security_group" "icmp" {
  name   = "allow-icmp-sg"
  vpc_id = aws_vpc.terprovd-vpc.id
}
resource "aws_security_group_rule" "icmp-rule-1" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.icmp.id
}


# Load balancer SGs
resource "aws_security_group" "websrvr-lb-sg" {
  name   = "websrvr-lb-sg"
  vpc_id = aws_vpc.terprovd-vpc.id
}
resource "aws_security_group_rule" "websrvr-lb-sg-r1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.terprovd-vpc.cidr_block]
  security_group_id = aws_security_group.websrvr-lb-sg.id
}
resource "aws_security_group_rule" "websrvr-lb-sg-r-all-out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.websrvr-lb-sg.id
}


resource "aws_security_group" "services-lb-sg" {
  name   = "services-lb-sg"
  vpc_id = aws_vpc.terprovd-vpc.id
}
resource "aws_security_group_rule" "services-lb-sg-r1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.terprovd-vpc.cidr_block]
  security_group_id = aws_security_group.services-lb-sg.id
}
resource "aws_security_group_rule" "services-lb-sg-r-all-out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.services-lb-sg.id
}


resource "aws_security_group" "processing-instance-sg" {
  name   = "processing-instance-sg"
  vpc_id = aws_vpc.terprovd-vpc.id
}
resource "aws_security_group_rule" "processing-instance-sg-r1" {
  type              = "ingress"
  from_port         = 6969
  to_port           = 6969
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.terprovd-vpc.cidr_block]
  security_group_id = aws_security_group.processing-instance-sg.id
}
resource "aws_security_group_rule" "processing-instance-sg-r-all-out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.processing-instance-sg.id
}


resource "aws_security_group" "query-instance-sg" {
  name   = "query-instance-sg"
  vpc_id = aws_vpc.terprovd-vpc.id
}
resource "aws_security_group_rule" "query-instance-sg-r1" {
  type              = "ingress"
  from_port         = 7070
  to_port           = 7070
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.terprovd-vpc.cidr_block]
  security_group_id = aws_security_group.query-instance-sg.id
}
resource "aws_security_group_rule" "query-instance-sg-r-all-out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.query-instance-sg.id
}
