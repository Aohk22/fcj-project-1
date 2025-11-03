data "aws_ami" "latest-img-file" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["ami-file*"]
  }
}

data "aws_ami" "latest-img-query" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["ami-query*"]
  }
}

resource "aws_launch_template" "web-server-lt" {
  name          = "web-server-lt"
  image_id      = "ami-01361d3186814b895" # AMI ID of your app
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-dynamodb-profile.name
  }

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
              nohup fastapi run --port 80 --host 0.0.0.0 > /var/log/http.log 2>&1 &
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
  image_id      = data.aws_ami.latest-img-file.id
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-dynamodb-profile.name
  }

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
              cd /home/app
              source .venv/bin/activate
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

resource "aws_launch_template" "query-service-lt" {
  name          = "query-service-lt"
  image_id      = data.aws_ami.latest-img-query.id
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-dynamodb-profile.name
  }

  key_name = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.query-instance-sg.id,
      aws_security_group.ssh.id,
      aws_security_group.icmp.id
    ]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              cd /home/app
              source .venv/bin/activate
              nohup fastapi run --port 7070 --host 0.0.0.0 > /var/log/http.log 2>&1 &
              EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "query-service-instance"
    }
  }
}
