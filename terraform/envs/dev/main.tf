data "aws_iam_policy_document" "fhandle_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  } 
}

data "aws_iam_policy_document" "fhandle_permission_policy" {
  statement {
    sid    = "DynamoDBFullAccess"
    effect = "Allow"
    actions = [ "dynamodb:*" ]
    resources = [ "arn:aws:dynamodb:*:*:table/*" ]
  }
}

module "instance_profile" {
  source                  = "../../modules/instance_profile"
  instance_profile_name   = "fhandle_instance_profile"
  iam_role_name           = "fhandle_iam_role"
  iam_policy_name         = "fhandle_policy"
  assume_role_policy_json = aws_iam_policy_document.fhandle_assume_role_policy.json
  permission_policy_json  = aws_iam_policy_document.fhandle_permission_policy.json
}

module "launch_template" {
  source                    = "../../modules/launch_template"
  key_name                  = aws_key_pair.deployer.key_name
  iam_instance_profile_name = module.instance_profile.instance_profile_name
  image_id = 
  network_interfaces = {
    public_ip          = false
  }
  tag_specifications = {
    tags = {
      Name = "fhandle_ec2"
    }
  }
}
