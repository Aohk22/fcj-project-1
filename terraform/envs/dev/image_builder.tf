data "aws_iam_policy_document" "perm_policy_imgbuilder" {
  statement {
    sid = "SSMAccess"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    sid = "EC2AndECRAccess"
    actions = [
      "ec2:Describe*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["*"]
  }

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

module "instance_profile_imgbuilder" {
  source                  = "../../modules/instance_profile"
  name                    = "imgbuilder_instance_profile"
  iam_role_name           = "imgbuilder_iam_role"
  iam_policy_name         = "imgbuilder_policy"
  assume_role_policy_json = data.aws_iam_policy_document.role_policy_ec2.json
  permission_policy_json  = data.aws_iam_policy_document.perm_policy_imgbuilder.json
}

resource "aws_iam_role_policy_attachment" "imgbuilder_ec2_profile" {
  role       = module.instance_profile_imgbuilder.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "imgbuilder_ec2_ecr_profile" {
  role       = module.instance_profile_imgbuilder.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

resource "aws_iam_role_policy_attachment" "imgbuilder_ssm_core" {
  role       = module.instance_profile_imgbuilder.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_imagebuilder_infrastructure_configuration" "imgbuilder_infra_config" {
  name                          = "imgbuilder_infra_config"
  instance_profile_name         = module.instance_profile_imgbuilder.instance_profile_name
  instance_types                = ["t2.nano", "t3.micro"]
  key_pair                      = aws_key_pair.terraform-key.key_name
  subnet_id                     = module.subnet_pub_1.id
  security_group_ids            = [aws_security_group.allow_all.id]
  terminate_instance_on_failure = true
}

module "image_builder_pipeline_fhandle" {
  source              = "../../modules/image_builder"
  pipeline_name       = "fhandle_img_pipeline"
  recipe_name         = "fhandle_img_recipe"
  recipe_parent_img   = "ami-0eeab253db7e765a9" // ubuntu server 2204.
  pipeline_infra_arn  = aws_imagebuilder_infrastructure_configuration.imgbuilder_infra_config.arn
  component_name      = "fhandle_component"
  component_data_yaml = file(var.component_data_fhandle_yaml)
}

module "image_builder_pipeline_fquery" {
  source              = "../../modules/image_builder"
  pipeline_name       = "fquery_img_pipeline"
  recipe_name         = "fquery_img_recipe"
  recipe_parent_img   = "ami-0eeab253db7e765a9" // ubuntu server 2204.
  pipeline_infra_arn  = aws_imagebuilder_infrastructure_configuration.imgbuilder_infra_config.arn
  component_name      = "fquery_component"
  component_data_yaml = file(var.component_data_fquery_yaml)
}
