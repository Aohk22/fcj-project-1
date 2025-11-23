data "aws_iam_policy_document" "perm_policy_dynamodb" {
  statement {
    sid       = "DynamoDBFullAccess"
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:*:*:table/*"]
  }
}

data "aws_ami" "ami_fhandle" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:Ec2ImageBuilderArn"
    values = ["arn:aws:imagebuilder:ap-southeast-2:005716755011:image/fhandle-img-recipe/1.0.0/*"]
  }
}

data "aws_ami" "ami_fquery" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:Ec2ImageBuilderArn"
    values = ["arn:aws:imagebuilder:ap-southeast-2:005716755011:image/fhandle-img-recipe/1.0.0/*"]
  }
}

module "instance_profile_dynamodb" {
  source                  = "../../modules/instance_profile"
  name                    = "dynamodb_instance_profile"
  iam_role_name           = "dynamodb_iam_role"
  iam_policy_name         = "dynamodb_policy"
  assume_role_policy_json = data.aws_iam_policy_document.role_policy_ec2.json
  permission_policy_json  = data.aws_iam_policy_document.perm_policy_dynamodb.json
}

module "launch_template_fhandle" {
  source                    = "../../modules/launch_template"
  name                      = "launch_template_fhandle"
  key_name                  = aws_key_pair.terraform-key.key_name
  iam_instance_profile_name = module.instance_profile_dynamodb.instance_profile_name
  image_id                  = data.aws_ami.ami_fhandle.id
  instance_type             = "t3.small"
  network_interfaces = {
    public_ip          = false
    security_group_ids = [aws_security_group.allow_all.id]
  }
  tag_specifications = {
    tags = {
      Name = "fhandle_ec2"
    }
  }
  user_data = file(var.lt_usr_data_fhandle_sh)
}

module "launch_template_fquery" {
  source                    = "../../modules/launch_template"
  name                      = "launch_template_fquery"
  key_name                  = aws_key_pair.terraform-key.key_name
  iam_instance_profile_name = module.instance_profile_dynamodb.instance_profile_name
  image_id                  = data.aws_ami.ami_fquery.id
  instance_type             = "t3.micro"
  network_interfaces = {
    public_ip          = false
    security_group_ids = [aws_security_group.allow_all.id]
  }
  tag_specifications = {
    tags = {
      Name = "fquery_ec2"
    }
  }
  user_data = file(var.lt_usr_data_fquery_sh)
}

module "launch_template_web" {
  source        = "../../modules/launch_template"
  name          = "launch_template_web"
  key_name      = aws_key_pair.terraform-key.key_name
  image_id      = "ami-0eeab253db7e765a9" // ubuntu server 2204.
  instance_type = "t3.micro"
  network_interfaces = {
    public_ip          = true
    security_group_ids = [aws_security_group.allow_all.id]
  }
  tag_specifications = {
    tags = {
      Name = "web_ec2"
    }
  }
  user_data = file(var.lt_usr_data_web_sh)
}
