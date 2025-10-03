# # WEBSERVER
# # First AZ (a)
# resource "aws_instance" "webserver-aza-ec2" {
#   ami           = "ami-01361d3186814b895"
#   instance_type = "t3.micro"
#
#   subnet_id                   = aws_subnet.terprovd-pub1-subnet.id
#   vpc_security_group_ids      = [aws_security_group.ssh.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.deployer.key_name
#
#   tags = {
#     Name = "webserver-ec2"
#   }
# }
# # Second AZ (b)
# resource "aws_instance" "webserver-azb-ec2" {
#   ami           = "ami-01361d3186814b895"
#   instance_type = "t3.micro"
#
#   subnet_id                   = aws_subnet.terprovd-pub2-subnet.id
#   vpc_security_group_ids      = [aws_security_group.ssh.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.deployer.key_name
#
#   tags = {
#     Name = "webserver-ec2"
#   }
# }
#
# # SERVICES
# # First AZ (a)
# resource "aws_instance" "process-srvc-aza-ec2" {
#   ami           = "ami-01361d3186814b895"
#   instance_type = "t3.micro"
#
#   subnet_id              = aws_subnet.terprovd-prv1-subnet.id
#   vpc_security_group_ids = []
#   key_name               = aws_key_pair.deployer.key_name
#
#   tags = {
#     Name = "webserver-ec2"
#   }
# }
resource "aws_instance" "query-srvc-aza-ec2" {
  ami           = "ami-01361d3186814b895"
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  subnet_id = aws_subnet.terprovd-prv1-subnet.id
  vpc_security_group_ids = [
    aws_security_group.query-instance-sg.id,
    aws_security_group.ssh.id,
    aws_security_group.icmp.id
  ]

  tags = {
    Name = "query-service-instance-a"
  }
}
# # Second AZ (b)
# resource "aws_instance" "process-srvc-azb-ec2" {
#   ami           = "ami-01361d3186814b895"
#   instance_type = "t3.micro"
#
#   subnet_id              = aws_subnet.terprovd-prv2-subnet.id
#   vpc_security_group_ids = []
#   key_name               = aws_key_pair.deployer.key_name
#
#   tags = {
#     Name = "webserver-ec2"
#   }
# }
resource "aws_instance" "query-srvc-azb-ec2" {
  ami           = "ami-01361d3186814b895"
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  subnet_id = aws_subnet.terprovd-prv2-subnet.id
  vpc_security_group_ids = [
    aws_security_group.query-instance-sg.id,
    aws_security_group.ssh.id,
    aws_security_group.icmp.id
  ]

  tags = {
    Name = "query-service-instance-b"
  }
}

####### TEMPLATES ########
resource "aws_launch_template" "web-server-lt" {
  name          = "web-server-lt"
  image_id      = "ami-01361d3186814b895" # AMI ID of your app
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.websrvr-lb-sg.id,
      aws_security_group.ssh.id
    ]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y git ssdeep python3 python3-venv python3-pip
              mkdir /app
              cd /app
              git clone https://github.com/Aohk22/fcj-project-1.git
              cd fcj-project-1
              git switch webserver-ec2
              python -m venv .venv
              source .venv/bin/activate
              pip install -r requirements.txt
              fastapi run --port 80 --host 0.0.0.0 &
              EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-instance"
    }
  }
  tags = {
    Name = "web-server-lt"
  }
}

resource "aws_launch_template" "processing-service-lt" {
  name          = "processing-service-lt"
  image_id      = "ami-01361d3186814b895" # AMI ID of your app
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.processing-instance-sg.id,
      aws_security_group.ssh.id,
      aws_security_group.icmp.id
    ]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y git ssdeep python3 python3-venv python3-pip
              mkdir /app
              cd /app
              git clone https://github.com/Aohk22/fcj-project-1.git
              cd fcj-project-1
              git switch file-processing-service
              python -m venv .venv
              source .venv/bin/activate
              pip install -r requirements.txt
              nohup fastapi run --port 6969 --host 0.0.0.0 > /var/log/http.log 2>&1 &
              EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "processing-service-instance"
    }
  }
}
