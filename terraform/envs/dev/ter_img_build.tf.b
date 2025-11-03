resource "aws_iam_role" "imagebuilder-role" {
  name = "imagebuilder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "imagebuilder.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "imagebuilder-policy" {
  role       = aws_iam_role.imagebuilder-role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_imagebuilder_component" "app-component-query" {
  name     = "app-install-query"
  platform = "Linux"
  version  = "1.0.0"

  data = <<EOF
name: AppInstallQuery
description: init
schemaVersion: 1.0

phases:
  - name: InstallSSMAgent
    action: ExecuteBash
    inputs:
      commands:
        - apt-get update -y
        - snap install amazon-ssm-agent --classic || apt-get install -y amazon-ssm-agent
        - systemctl enable amazon-ssm-agent
        - systemctl start amazon-ssm-agent
  - name: build
    steps:
      - name: InstallDeps
        action: ExecuteBash
        inputs:
          commands:
            - apt-get update -y
            - apt-get install -y git  python3 python3-venv python3-pip

      - name: SetupUser
        action: ExecuteBash
        inputs:
          commands:
            - useradd -ms /bin/bash app
            - mkdir -p /home/app
            - chown -R app:app /home/app

      - name: CloneRepo
        action: ExecuteBash
        inputs:
          commands:
            - sudo -u app git clone https://github.com/Aohk22/fcj-project-1.git /home/app

      - name: SetupPythonEnv
        action: ExecuteBash
        inputs:
          commands:
            - cd /home/app
            - git switch query-service
            - sudo -u app python3 -m venv .venv
            - sudo -u app bash -c "source /home/app/.venv/bin/activate && pip install --no-cache-dir -r requirements.txt"
EOF
}

resource "aws_imagebuilder_component" "app-component-file" {
  name     = "app-install-file"
  platform = "Linux"
  version  = "1.0.0"

  data = <<EOF
name: AppInstallQuery
description: Install ssdeep, Python, and clone repository on Ubuntu 22.04
schemaVersion: 1.0

phases:
  - name: InstallSSMAgent
    action: ExecuteBash
    inputs:
      commands:
        - apt-get update -y
        - snap install amazon-ssm-agent --classic || apt-get install -y amazon-ssm-agent
        - systemctl enable amazon-ssm-agent
        - systemctl start amazon-ssm-agent
  - name: build
    steps:
      - name: InstallDeps
        action: ExecuteBash
        inputs:
          commands:
            - apt-get update -y
            - apt-get install -y git ssdeep python3 python3-venv python3-pip file

      - name: SetupUser
        action: ExecuteBash
        inputs:
          commands:
            - useradd -ms /bin/bash app
            - mkdir -p /home/app
            - chown -R app:app /home/app

      - name: CloneRepo
        action: ExecuteBash
        inputs:
          commands:
            - sudo -u app git clone https://github.com/Aohk22/fcj-project-1.git /home/app

      - name: SetupPythonEnv
        action: ExecuteBash
        inputs:
          commands:
            - cd /home/app
            - git switch file-processing-service
            - sudo -u app python3 -m venv .venv
            - sudo -u app bash -c "source /home/app/.venv/bin/activate && pip install --no-cache-dir -r requirements.txt"
EOF
}

resource "aws_imagebuilder_image_recipe" "img-recipe-query" {
  name         = "img-recipie-query"
  version      = "1.0.0"
  parent_image = "ami-01361d3186814b895"
  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
    }
  }

  component {
    component_arn = aws_imagebuilder_component.app-component-query.arn
  }

  tags = {
    Name = "ami-query"
  }
}

resource "aws_imagebuilder_image_recipe" "img-recipe-file" {
  name         = "img-recipie-file"
  version      = "1.0.0"
  parent_image = "ami-01361d3186814b895"
  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
    }
  }

  component {
    component_arn = aws_imagebuilder_component.app-component-file.arn
  }

  tags = {
    Name = "ami-file"
  }
}

resource "aws_iam_instance_profile" "imagebuilder-profile" {
  name = "imagebuilder-instance-profile"
  role = aws_iam_role.imagebuilder-role.name
}

resource "aws_imagebuilder_infrastructure_configuration" "infra" {
  name                  = "img-infra"
  instance_profile_name = aws_iam_instance_profile.imagebuilder-profile.name
  instance_types = ["t3.micro"]
  key_pair = aws_key_pair.deployer.key_name
}

resource "aws_imagebuilder_image_pipeline" "pipeline-file" {
  name                             = "img-pipeline-file"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.img-recipe-file.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.infra.arn
  tags = {
    Name = "img-pipeline-file"
  }
}

resource "aws_imagebuilder_image_pipeline" "pipeline-query" {
  name                             = "img-pipeline-query"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.img-recipe-query.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.infra.arn
  tags = {
    Name = "img-pipeline-query"
  }
}
