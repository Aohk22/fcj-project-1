# instancing
resource "aws_instance" "webserver-ec2" {
  ami           = "ami-01361d3186814b895"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.terprovd-pub1-subnet.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  tags = {
    Name = "webserver-ec2"
  }
}
